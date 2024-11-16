"""
Author: vic123 zhangzc_efz@163.com
Date: 2024-09-03 16:48:14
LastEditors: vic123 zhangzc_efz@163.com
LastEditTime: 2024-09-12 18:13:16
FilePath: \Video-Streaming-Using-WebSockets\server\server.py
Description: 

Copyright (c) 2024 by vic123, All Rights Reserved. 
"""

import json
import websockets
import asyncio
import cv2, base64
import sys
import base64
import numpy as np
import csv
from PIL import Image
from PIL.ExifTags import TAGS
import io
import time
from datetime import datetime

port = 5000
lock = asyncio.Lock()
print("Started server on port:", port)


def draw_corr():
    canvas = np.zeros((480, 720, 3), dtype="uint8")

    # 设置要显示的数字和其位置
    numbers = [
        "yaw" + str(yaw),
        "pitch" + str(pitch),
        "raw" + str(raw),
        "x" + str(x + offsetx),
        "y" + str(y + offsety),
        "z" + str(z + offsetz),
    ]
    positions = [(50, 50), (50, 100), (50, 150), (50, 200), (50, 250), (50, 300)]

    # 设置字体、颜色和大小
    font = cv2.FONT_HERSHEY_SIMPLEX
    font_scale = 1
    color = (255, 255, 255)  # 白色
    thickness = 2

    # 将数字绘制到画面上
    for number, position in zip(numbers, positions):
        cv2.putText(canvas, number, position, font, font_scale, color, thickness)
    return canvas


async def send(websocket):
    global evaluator, x, y, z, offsetx, offsety, offsetz, yaw, pitch, raw
    print("Client Connected!")
    await websocket.send("Connection Established")
    try:
        while True:
            frame = draw_corr()
            encoded = cv2.imencode(".jpg", frame)[1]
            data = str(base64.b64encode(encoded))
            data = data[2 : len(data) - 1]
            await websocket.send(data)

        # cap.release()
    except:
        print("Client Disconnected!")


async def receive(websocket):
    # try:
    cnt = 0
    gyroFlag = 0
    accFlag = 0
    # file_handle = open("..\\data\\output.csv", mode="w", newline="")
    gyroAccDict = {
        "timestamp": 0,
        "omega_x": 0,
        "omega_y": 0,
        "omega_z": 0,
        "alpha_x": 0,
        "alpha_y": 0,
        "alpha_z": 0,
    }
    # writer = csv.DictWriter(file_handle, fieldnames=gyroAccDict.keys())
    # writer.writeheader()
    while True:
        message = await websocket.recv()  # Wait for a message from the client
        cnt += 1
        if (
            sys.getsizeof(message) < 2**10
        ):  # Todo: tell picture from string message in a more elegant way
            try:
                message = json.loads(message)
                if message["code"] == "orientationUpdate":
                    await orientationUpdate(message)
                elif message["code"] == "scaleUpdate":
                    await scaleUpdate(message)
                elif message["code"] == "scaleEnd":
                    await scaleEnd(message)
                elif message["code"] == "accelerometer":
                    if gyroFlag == 1:
                        gyroAccDict["alpha_x"] = message["x"]
                        gyroAccDict["alpha_y"] = message["y"]
                        gyroAccDict["alpha_z"] = message["z"]
                    else:
                        gyroAccDict["alpha_x"] = message["x"]
                        gyroAccDict["alpha_y"] = message["y"]
                        gyroAccDict["alpha_z"] = message["z"]
                        gyroAccDict["timestamp"] = message["timestamp"] * 1000
                    accFlag = 1
                elif message["code"] == "gyroscope":
                    if accFlag == 1:
                        gyroAccDict["omega_x"] = message["x"]
                        gyroAccDict["omega_y"] = message["y"]
                        gyroAccDict["omega_z"] = message["z"]
                    else:
                        gyroAccDict["omega_x"] = message["x"]
                        gyroAccDict["omega_y"] = message["y"]
                        gyroAccDict["omega_z"] = message["z"]
                        gyroAccDict["timestamp"] = message["timestamp"] * 1000
                    gyroFlag = 1
                # print("Received message from client:", message)
            except:
                pass
            if gyroFlag == 1 and accFlag == 1:
                # writer.writerow(gyroAccDict)
                gyroFlag = 0
                accFlag = 0
        else:
            message = json.loads(message)

            pic_base64 = message["image"]
            pic = base64.b64decode(pic_base64)
            image = Image.open(io.BytesIO(pic))
            exif_data = image._getexif()
            timestamp = 0
            datetime_original = None
            subsec_time_original = None
            subsec_seconds = None
            if exif_data:
                for tag, value in exif_data.items():
                    tag_name = TAGS.get(tag, tag)
                    if tag_name == "DateTimeOriginal":
                        datetime_original = value
                        print("datetime", datetime_original)
                    # 查找亚秒部分
                    elif tag_name == "SubsecTimeOriginal":
                        subsec_time_original = value
                        print("subsec", subsec_time_original)
            if datetime_original:
                datetime_obj = datetime.strptime(datetime_original, "%Y:%m:%d %H:%M:%S")

                timestamp = int(time.mktime(datetime_obj.timetuple()))

                if subsec_time_original:
                    subsec_seconds = str(subsec_time_original)

            # with open(
            #     "..\\data\\cam0\\" + str(timestamp) + subsec_seconds + "000" + ".png",
            #     "wb",
            # ) as f:
            #     f.write(pic)


def YawPitchRaw2RotationMatrix(yaw, pitch, raw):
    Yaw = np.array(
        [[np.cos(yaw), 0, np.sin(yaw)], [0, 1, 0], [-np.sin(yaw), 0, np.cos(yaw)]],
        dtype=np.float32,
    )
    Pitch = np.array(
        [
            [1, 0, 0],
            [0, np.cos(pitch), -np.sin(pitch)],
            [0, np.sin(pitch), np.cos(pitch)],
        ],
        dtype=np.float32,
    )
    Raw = np.array(
        [[np.cos(raw), -np.sin(raw), 0], [np.sin(raw), np.cos(raw), 0], [0, 0, 1]],
        dtype=np.float32,
    )
    return np.dot(np.dot(Yaw, Pitch), Raw)


async def scaleUpdate(message):
    global x, y, z, offsetx, offsety, offsetz, yaw, pitch, raw
    RotationMatrix = YawPitchRaw2RotationMatrix(yaw, pitch, raw)
    async with lock:
        offsetx = RotationMatrix[0][2] * (message["scale"] - 1)
        offsety = RotationMatrix[1][2] * (message["scale"] - 1)
        offsetz = RotationMatrix[2][2] * (message["scale"] - 1)


async def orientationUpdate(message):
    global yaw, pitch, raw, x, y, z, offsetx, offsety, offsetz
    async with lock:
        yaw += message["yaw"] / 200
        pitch -= message["pitch"] / 200


async def scaleEnd(message):
    global offsetx, offsety, offsetz, x, y, z, scale
    async with lock:
        x += offsetx
        y += offsety
        z += offsetz
        offsetx = 0
        offsety = 0
        offsetz = 0
        scale = 1
    print("yaw", yaw, "pitch", pitch, "raw", raw, "x", x, "y", y, "z", z)


async def handle(websocket, path):
    send_task = asyncio.create_task(send(websocket))
    receive_task = asyncio.create_task(receive(websocket))
    await asyncio.gather(send_task, receive_task)


async def main():
    async with websockets.serve(handle, "0.0.0.0", 5000, max_size=2**30):
    # async with websockets.serve(handle, "localhost", 5000, max_size=2**30):
        print("WebSocket服务器已启动，监听端口 5000")
        await asyncio.Future()


yaw, pitch, raw, x, y, z, offsetx, offsety, offsetz = (
    1.5,
    0.3,
    3.1415926,
    0.4508,
    0.3173,
    0.3940,
    0.0,
    0.0,
    0.0,
)
asyncio.run(main())
