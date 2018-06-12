from __future__ import print_function

import boto3
import time

#this function for Invalidtion online cf prefix /event/* , DistributionId is prd cf id

def lambda_handler(event, context):
    for items in event["Records"]:
        if items["s3"]["object"]["key"] == "index.html":
            online_path = "/event/*"
            event_path = "/*"
        else:
            online_path = "/event/" + items["s3"]["object"]["key"]
            online_path = online_path.replace("index.html","*")
            event_path = "/" + items["s3"]["object"]["key"]
            event_path = event_path.replace("index.html","*")
    print(online_path)
    print(event_path)

    client = boto3.client('cloudfront')

    #invalidation online cf
    online_invalidation = client.create_invalidation(DistributionId='E3GBMF8LIN6LTI',
        InvalidationBatch={
            'Paths': {
                'Quantity': 1,
                'Items': [online_path]
        },
        'CallerReference': str(time.time())
    })

    #invalidation event bucket cf
    event_invalidation = client.create_invalidation(
        DistributionId='E2HP453OV90CZF',
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': [event_path]
            },
            'CallerReference': str(time.time())
    })