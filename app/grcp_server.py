# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

import grpc
from concurrent import futures
import grcp_pb2_grpc as pb2_grpc
import grcp_pb2 as pb2
from grpc_reflection.v1alpha import reflection


class grcpService(pb2_grpc.grcpServicer):

    def __init__(self, *args, **kwargs):
        pass

    def GetServerResponse(self, request, context):

        # get the string from the incoming request
        message = request.message
        result = f'Server Hello world. Received message is {message}'
        result = {'message': result, 'received': True}

        return pb2.MessageResponse(**result)


def serve():
    server = grpc.server(futures.ThreadPoolExecutor(max_workers=10))
    pb2_grpc.add_grcpServicer_to_server(grcpService(), server)
    SERVICE_NAMES = (
        pb2.DESCRIPTOR.services_by_name['grcp'].full_name,
        reflection.SERVICE_NAME,
    )
    reflection.enable_server_reflection(SERVICE_NAMES, server)
    server.add_insecure_port('[::]:80')
    server.start()
    server.wait_for_termination()


if __name__ == '__main__':
    serve()