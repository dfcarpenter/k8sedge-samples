import asyncio 
import logging
from asyncua import Client, Node, ua 
import os 
import signal
from ssl import SSLContext 
import time 

import logging 
import threading 

from gmqtt import Client as MQTTClient 

fetch_interval = 1 # seconds

logging.basicConfig(level=logging.INFO)
_logger = logging.getLogger('opcua-monitoring')


STOP = asyncio.Event()

def on_connect(client, flags, rc, properties):
    print('Connected')
    client.subscribe('RESPONSE/#', qos=0)


def on_message(client, topic, payload, qos, properties):
    print('RECV MSG:', payload)


def on_disconnect(client, packet, exc=None):
    print('Disconnected')

def on_subscribe(client, mid, qos, properties):
    print('SUBSCRIBED')

def ask_exit(*args):
    STOP.set()

def assign_callbacks_to_client(client):
    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    client.on_subscribe = on_subscribe

class SubscriptionHandler:
    """
    Subscription Handler. To receive events from server for a subscription
    """

    def datachange_notification(self, node: Node, val, data):
        """
        Callback for asyncua Subscription.
        This method will be called when the Client received a dat achange message from the Server.
        """
        _logger.info(f"data change event {node} {val}")


async def main():

    mqtt_client = MQTTClient("umati-mqtt")


    mqtt_client.set_auth_credentials('client1', 'password')

    await mqtt_client.connect('192.168.0.4')

    assign_callbacks_to_client(mqtt_client)

    try:

        client = Client(url='opc.tcp://umatiopc.westus3.azurecontainer.io:4840/UA')

        async with client:
            idx = await client.get_namespace_index("http://opcfoundation.org/UA/")
            var = await client.nodes.objects.get_child([f"{idx}:MyObject", f"{idx}:MyVariable"])
            handler = SubscriptionHandler()

            # We create a Client subscription 
            subscription = await client.create_subscription(500, handler)
            nodes = [
                var, 
                client.get_node(ua.ObjectIds.Server_ServerStatus_CurrentTime),
            ]

            handle = await subscription.subscribe_data_change(nodes)
            global _handler, _handle, _client, _subscription 
            _handle = handle 
            _client = client 
            _subscription = subscription
            mqtt_client.publish('umati-telemetry', "python mqtt message", 'RESPONSE/umati')
            await asyncio.sleep(0.1)
            
    finally:
        print("Exit python application")

        if _handle and _subscription:
            await _subscription.unsubscribe(_handle)
            await _subscription.delete()
        if _client:
            await _client.disconnect


asyncio.run(main)