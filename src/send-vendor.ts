import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import AWS from 'aws-sdk';
import { dynamoDbScanTable, sendMessageWebsocket } from './aws';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    const tableName = process.env.AWS_TABLE_NAME ?? '';
    const apigwManagementApi = new AWS.ApiGatewayManagementApi({
        apiVersion: '2018-11-29',
        endpoint: event.requestContext.domainName + '/' + event.requestContext.stage
    });

    console.log('scanning table')
    
    const res = await dynamoDbScanTable(tableName);
    if (res instanceof Error) {
        console.log('error', res.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : res.message
        }
    }

    const connections = res.Items;
    console.log(event.requestContext.domainName + '/' + event.requestContext.stage)
    console.log(connections);
    // await sendMessageWebsocket(apigwManagementApi)
    // await apigwManagementApi.postToConnection({ ConnectionId: connectionId, Data: connectionId }).promise();

    // console.log(`Sent message to ${res.Count} users!`);
    
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `Sent message to ${res.Count} users!`,
        }),
    };
};
