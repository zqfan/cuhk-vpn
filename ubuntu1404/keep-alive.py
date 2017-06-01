import requests
import time

while True:
    print requests.get('https://www.google.com')
    time.sleep(10)
