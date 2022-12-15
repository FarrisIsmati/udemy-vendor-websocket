import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { dynamoDbRemoveConnection } from './aws';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    const tableName = process.env.AWS_TABLE_NAME ?? '';
    const connectionId = event.requestContext.connectionId ?? '';
    console.log('attempt user:', connectionId)
    
    const res = await dynamoDbRemoveConnection(tableName, connectionId);
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

    console.log('removed!');
    
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `User ${connectionId} removed!`,
        }),
    };
};
