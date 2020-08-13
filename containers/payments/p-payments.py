from flask import Flask, render_template, request, jsonify
import requests
import json
import random
import socket


app = Flask(__name__)
flaskPort=5003

@app.route('/')
def index():
    serviceName = 'payments'
    #hostname = socket.gethostname()
    #ip_address = socket.gethostbyname(hostname)
    return jsonify(response=200)



if __name__ == '__main__':
    app.run(debug=True, port=flaskPort)