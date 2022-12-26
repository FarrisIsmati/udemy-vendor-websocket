import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import AWS from 'aws-sdk';
import { broadcastMessageWebsocket, dynamoDbScanTable, sqsDeleteMessage } from './aws';

// env
const AWS_SQS_URL = process.env.AWS_SQS_URL ?? '';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(JSON.stringify(event))
    console.log(JSON.stringify(context))
    console.log('---')

    const tableName = process.env.AWS_TABLE_NAME ?? '';
    const apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: '2018-11-29',
        endpoint: event.requestContext.domainName + '/' + event.requestContext.stage
    });

    if (!event.body) {
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : `event body empty or null ${event.body}`
        }
    }

    console.log('scanning table')
    
    const dbRes = await dynamoDbScanTable(tableName);
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

    // Future use case how would a user handle broadcasting message to hundreds of thousands + people
    const broadcastRes = await broadcastMessageWebsocket({
        apiGatewayManagementApi: apigwManagementApi, 
        connections: dbRes.Items as AWS.DynamoDB.ItemList, 
        message: event.body as string,
        tableName
    });
    if (broadcastRes instanceof Error) {
        console.log('error', broadcastRes.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : broadcastRes.message
        }
    }
    console.log(`Sent message ${event.body} to ${dbRes.Count} users!`);
    

    // TODO DELETE SQS MESSAGE
    const deleteMessageRes = await sqsDeleteMessage(AWS_SQS_URL, event.body)
    if (deleteMessageRes instanceof Error) {
        console.log('error', deleteMessageRes.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : deleteMessageRes.message
        }
    }

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Sent message to ${dbRes.Count} users!`,
        }),
    };
};
