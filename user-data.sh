#!/bin/bash

# THIS IS A MUST IN ORDER TO REGISTER A EC2 FROM AMI TO ECS

# ECS config
{
  echo "ECS_CLUSTER=${cluster_name}"
} >> /etc/ecs/ecs.config

start ecs

echo "Done"
