import { APIGatewayEvent, APIGatewayProxyResult, SQSEvent } from 'aws-lambda';
import AWS from 'aws-sdk';
import { broadcastMessageWebsocket, dynamoDbScanTable, sqsDeleteMessage } from './aws';

// env
const AWS_HTTP_URL = process.env.AWS_HTTP_URL ?? '';
const TABLE_NAME = process.env.AWS_TABLE_NAME ?? '';

export const handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
    console.log('stringed event');
    console.log(JSON.stringify(event));

    // Endpoint needs to remove the http:// from url
    const endpoint = new URL(AWS_HTTP_URL);
    const apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: '2018-11-29',
        endpoint: endpoint.hostname + endpoint.pathname
    });

    const message = event.body;

    if (!message) {
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : `event message empty or null ${message}`
        }
    }

    console.log('scanning table')
    const scanTableGen = await dynamoDbScanTable(TABLE_NAME);
    if (scanTableGen instanceof Error) {
        console.log('error', scanTableGen.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : scanTableGen.message
        }
    }

    const iterator = await scanTableGen.next();

    console.log('iterator!');
    console.log(JSON.stringify(iterator));

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Jablowme`,
        }),
    };
};
