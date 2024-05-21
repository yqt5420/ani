import os
import platform
from pathlib import Path
import time
import requests
import json
import urllib.parse as parse

alist_username = "admin"
alist_password = "A12345678a"
alist_url = "http://us.247200.xyz:5244"
listen_path = "/root/pan/Bangumi"
path_key = "Bangumi"
pan_driver='/Anime'

def get_token():
   payload = json.dumps({
      "username": alist_username,
      "password": alist_password
   })
   headers = {
      'User-Agent': 'Apifox/1.0.0 (https://apifox.com)',
      'Content-Type': 'application/json'
   }

   response = requests.request("POST", alist_url + "/api/auth/login", headers=headers, data=payload).json()
   return response['data']['token']


def upload_file(file_path, token):
   tmp = file_path.split(path_key)[-1]
   os_name = platform.system()
   if os_name == 'Windows':
      pan_path = pan_driver + tmp.replace('\\', '/')
   elif os_name == 'Linux':
      pan_path = pan_driver + tmp

   headers = {
      'Authorization': token,
      'File-Path': parse.quote(pan_path),
      'As-Task': 'true'
   }
   with open(file_path, 'rb') as payload:
      with requests.Session() as s:
         response = s.request("PUT", alist_url + "/api/fs/put", headers=headers, data=payload).json()
         time.sleep(5)
   return response["message"], parse.unquote(pan_path)


def trans_file(pan_path, file_path):
   n_file_path =  file_path + '.strm'
   local_file = alist_url + '/d' + pan_path
   os.makedirs(os.path.dirname(n_file_path), exist_ok=True)
   with open(n_file_path, 'w') as file:
      file.write(local_file)
      print(f'{n_file_path}写入成功！')
   os.remove(file_path)
   print(f"{file_path} 删除成功~~")


def up(file_path):
   try:
      token = get_token()
      res = upload_file(file_path, token)
      if "success" in res[0]:
         trans_file(res[1], file_path)
      else:
         print(f'{file_path} 上传出错！！')
   except Exception as e:
      print(e)


def main():
   folder_path = Path(listen_path)
   # 获取所有媒体文件路径
   video_files = [file for file in folder_path.rglob('*') if file.is_file() and file.suffix in ['.mkv', '.mp4']]
   print(f'获取到 {len(video_files)} 个视频文件')
   # 计算大小
   total_size = sum(file.stat().st_size for file in video_files)
   if total_size > 2 * 1024 * 1024 * 1024:  # 2GB in bytes
      for video_file in sorted(video_files):
         print(f"正在上传{str(video_file)}")
         up(str(video_file))
   else:
      print('磁盘空间充足，1min后重新检测！')
      time.sleep(60)


while True:
   main()
