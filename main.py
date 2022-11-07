import asyncio 
import os 
import signal
from ssl import SSLContext 
import time 

from gmqtt import Client as MQTTClient 


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



    # generate SAS token
    
async def az_dps_register():

    def generate_sas_token(uri, key, policy_name, expiry=3600):
        from base64 import b64encode, b64decode
        from hashlib import sha256
        from hmac import HMAC
        from time import time

        ttl = time() + expiry
        uri = f"{DPS_HOSTNAME}/registrations/{REGISTRATION_ID}/api-version=2018-11-01"
        sign_key = uri + "\n" + str(ttl)
        signature = b64encode(HMAC(b64ecode(IOT_KEY), sign_key.encode('utf-8'), sha256).digest())

        return f"SharedAccessSignature sr={uri}&sig={signature}&se={expiry}&skn=registration"
    
    ssl_context = SSLContext(protocol=PROTOCOL_TLS_CLIENT)
    ssl_context.load_default_certs()
    ssl_context.verify_mode = CERT_REQUIRED 
    ssl_context.check_hostname = True

    dpsclient = MQTTClient("{idScope}/registrations/{registration_id}/api-version=2019-03-31")

    dpsclient.tls_set_context(context=ssl_context)
    
    await dpsclient.connect('global.azure-devices-provisioning.net')
    dpsclient.publish('$dps/registrations/PUT/iotdps-register/?$rid={request_id}')
    # subscribe to the DPS topic
    dpsclient.subscribe('$dps/registrations/res/202/?$rid={request_id}')



async def main(broker_host, credentials):

    client = MQTTClient("registrationid")

    client.on_connect = on_connect
    client.on_message = on_message
    client.on_disconnect = on_disconnect
    client.on_subscribe = on_subscribe

    client.set_auth_credentials('username', 'password')

    await client.connect(broker_host)


asyncio.run(main('localhost', ('username', 'password')))

    
