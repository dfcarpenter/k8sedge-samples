import asyncio 
import logging
from asyncua import Client, Node, ua 

logging.basicConfig(level=logging.INFO)
_logger = logging.getLogger('opcua-monitoring')

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

async def child1():
    print(" child1: started! sleeping now...")
    await trio.sleep(1)
    print(" child1: done sleeping!")

async def child2():
    print(" child2: started! sleeping now...")
    await trio.sleep(1)
    print(" child2: done sleeping!")

async def main():

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

        await subscription.subscribe_data_change(nodes)

        await asyncio.sleep(10)

        await subscription.delete()

        await asyncio.slee(1)


asyncio.run(main)