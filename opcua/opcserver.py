import logging
import json
import asyncio
import pandas as pd

import socket

from asyncua import ua, Server 
from asyncua.common.methods import uamethod

logging.basicConfig(level=logging.INFO)
_logger = logging.getLogger('asyncua')


@uamethod
def func(parent, value):
    return value * 2


async def main():

    server = Server()
    await server.init()

    server.set_endpoint("opc.tcp://127.0.0.1:48040/opcua/")
    server.set_server_name("OPC-UA Server")

    # setup our own namespace, not really necessary but should as spec requires
    uri = "http://microsoft.com/opcua/"
    idx = await server.register_namespace(uri)

    # populating our address space
    # server.nodes, contains links to very common nodes like objects and root
    obj_vplc = await server.nodes.objects.add_object(idx, "vPLC1")
    var_temperature = await obj_vplc.add_variable(idx, "Temperature", 0)
    var_pressure = await obj_vplc.add_variable(idx, "Pressure", 0)
    var_pumpsetting = await obj_vplc.add_variable(idx, "PumpSetting", 0)


    await server.nodes.objects.add_method(
        ua.NodeId("ServerMethod", idx),
        ua.QualifiedName("ServerMethod", idx),
    )


    async with server:

        while True:
            # read data from csv
            df = pd.read_csv('data.csv')
            # get the last row
            last_row = df.iloc[-1]
            # get the values from the last row
            temperature = last_row['Temperature']
            pressure = last_row['Pressure']
            pumpsetting = last_row['PumpSetting']

            # set the values to the variables
            await var_temperature.write_value(temperature)
            await var_pressure.write_value(pressure)
            await var_pumpsetting.write_value(pumpsetting)

            await asyncio.sleep(1)

asyncio.run(main())


