import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { dynamoDbAddConnection } from './aws';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    const tableName = process.env.AWS_TABLE_NAME ?? '';
    const connectionId = event.requestContext.connectionId ?? '';
    console.log('user attempting to connect:', connectionId)
    const res = await dynamoDbAddConnection(tableName, connectionId);
    if (res instanceof Error) {
        console.log('Error', res.message)
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : res.message
        }
    }
    console.log('connected');

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `User ${connectionId} connected!`,
        }),
    };
};
