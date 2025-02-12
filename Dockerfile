# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

FROM python:3.8
#FROM registry.access.redhat.com/ubi8/python-38
ADD app/ /
RUN pip install -r requirements.txt

EXPOSE 80
CMD [ "python", "./grcp_server.py"]
