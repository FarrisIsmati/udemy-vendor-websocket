import { APIGatewayEvent, APIGatewayProxyResult, SQSEvent } from 'aws-lambda';
import AWS from 'aws-sdk';
import { broadcastMessageWebsocket, dynamoDbScanTable, sqsDeleteMessage } from './aws';

// env
const AWS_HTTP_URL = process.env.AWS_HTTP_URL ?? '';
const TABLE_NAME = process.env.AWS_TABLE_NAME ?? '';

export const handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
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
    const dbRes = await dynamoDbScanTable(TABLE_NAME);
    if (dbRes instanceof Error) {
        console.log('error', dbRes.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : dbRes.message
        }
    }

    console.log('stringed event');
    console.log(JSON.stringify(event));

    console.log('dbRes!');
    console.log(JSON.stringify(dbRes));
    // // Future use case how would a user handle broadcasting message to hundreds of thousands + people
    // const broadcastRes = await broadcastMessageWebsocket({
    //     apiGatewayManagementApi: apigwManagementApi, 
    //     connections: dbRes.Items as AWS.DynamoDB.ItemList, 
    //     message: message,
    //     tableName: TABLE_NAME
    // });
    // if (broadcastRes instanceof Error) {
    //     console.log('error', broadcastRes.message)
    //     return {
    //         "statusCode" : 500,
    //         "headers" : {
    //             "content-type": "text/plain; charset=utf-8"
    //         },
    //         "body" : broadcastRes.message
    //     }
    // }
    // console.log(`Sent message ${message} to ${dbRes.Count} users!`);
    
    // const deleteMessageRes = await sqsDeleteMessage(AWS_SQS_URL, event.Records[0].receiptHandle)
    // if (deleteMessageRes instanceof Error) {
    //     console.log('error', deleteMessageRes.message)
    //     return {
    //         "statusCode" : 500,
    //         "headers" : {
    //             "content-type": "text/plain; charset=utf-8"
    //         },
    //         "body" : deleteMessageRes.message
    //     }
    // }

    return {
        statusCode: 200,
        body: JSON.stringify({
            // message: `Sent message to ${dbRes.Count} users!`,
        }),
    };
};
