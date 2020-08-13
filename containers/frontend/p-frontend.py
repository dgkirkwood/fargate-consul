from flask import Flask, render_template, request
import requests
import json
import random
import os
import socket
import sys


app = Flask(__name__)
hostIP = '127.0.0.1'

@app.route('/')
def index():
    service_list = ["checkout", "payments"]
    return render_template('index.html', services=service_list)


@app.route('/service1')
def services():
    text = request.args.get('jsdata')

    if text:
        if text == 'recommendations' or text == 'mysql':
            r = requests.get('http://' + hostIP + ':8500/v1/catalog/service/'+ text + '?dc=dc-aws')
            if r.text.startswith('['):
                catResponse = r.text
                rjson = json.loads(catResponse)

            else:
                catResponse = '[]'
                rjson = json.loads(catResponse)

        else:
            r = requests.get('http://' + hostIP + ':8500/v1/catalog/service/'+ text)
            catResponse = r.text
            rjson = json.loads(catResponse)

        if len(rjson) == 0:
            svcName = text
            svcDc = 'NotFound'
            svcAddr = 'NotFound'
            svcPort = 'NotFound'
            response = 'NotFound'
            svc_attributes_list = [svcName, svcDc, svcAddr, svcPort]
            calloutClass = 'callout alert'

        else:
            random_choice = random.randint(0,(len(rjson)-1))
            svcName = rjson[random_choice]['ServiceName']
            svcDc = rjson[random_choice]['Datacenter']
            svcAddr = rjson[random_choice]['Address']
            nodeAddr = rjson[random_choice]['Address']
            if len(svcAddr) == 0 and len(nodeAddr) > 0:
                svcAddr = 'localhost'
            svcPort = rjson[random_choice]['ServicePort']
            svc_attributes_list = [svcName, svcDc, svcAddr, svcPort]
            if svcName == 'mysql':
                try:
                    tcp_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
                    server = ('127.0.0.1', 3306)
                    tcp_sock.connect(server)
                    response = '200'
                    calloutClass = 'callout success'
                except:
                    response = 'API Error'
                    calloutClass = 'callout warning'
            else:
                try:
                    rping = requests.get('http://' + '127.0.0.1' + ':' + str(svcPort))
                    response = rping.status_code
                    print(svcAddr)
                    print(response)
                    calloutClass = 'callout success'
                except:
                    response = 'API Error'
                    calloutClass = 'callout warning'

        return render_template('servicecard.html', suggestions=svc_attributes_list, response=response, calloutClass=calloutClass)


if __name__ == '__main__':
    app.run(host='0.0.0.0')