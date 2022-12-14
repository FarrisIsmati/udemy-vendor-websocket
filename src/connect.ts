import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';
import { dynamoDbAddConnection } from './aws';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);

    const tableName = process.env.AWS_TABLE_NAME ?? '';
    const connectionId = event.requestContext.connectionId ?? '';

    const res = await dynamoDbAddConnection(tableName, connectionId);
    if (res instanceof Error) {
        return {
            "statusCode" : 500,
            "headers" : {
                "content-type": "text/plain; charset=utf-8"
            },
            "body" : res.message
        }
    }

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: `User ${connectionId} connected!`,
        }),
    };
};
