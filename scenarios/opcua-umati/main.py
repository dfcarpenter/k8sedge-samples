import asyncio 
import os 
import signal
from ssl import SSLContext 
import time 
import grpc 
import logging 
import threading 

from gmqtt import Client as MQTTClient 

fetch_interval = 1 # seconds


STOP = asyncio.Event()

def on_connect(client, flags, rc, properties):
    print('Connected')
    client.subscribe('TEST/#', qos=0)


def on_message(client, topic, payload, qos, properties):
    print('RECV MSG:', payload)


def on_disconnect(client, packet, exc=None):
    print('Disconnected')

def on_subscribe(client, mid, qos, properties):
    print('SUBSCRIBED')

def ask_exit(*args):
    STOP.set()

def continuously_get_values():
    url = get_grpc_url()
    logging.info(f"Starting to call GetValue on endpoint {url}")
    while True:
        try:
            channel = grpc.insecure_channel(url, options=(
                ('grpc.use_local_subchannel_pool', 1),
            ))
            stub = ""
            value_response = ""
            channel.close()
            time.sleep(fetch_interval)
        except:
            logging.info("[%s] Exception %s" % (url, traceback.format_exc()))
            time.sleep(fetch_interval)

def assign_callbacks_to_client(client):
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    client.on_subscribe = on_subscribe


async def main(broker_host, credentials):

    client = MQTTClient("opc-plc-cnc-2")


    client.set_auth_credentials('username', 'password')

    await client.connect(broker_host)


asyncio.run(main('localhost', ('username', 'password')))

    
