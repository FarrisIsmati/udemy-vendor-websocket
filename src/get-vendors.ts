import { marshall, unmarshall } from '@aws-sdk/util-dynamodb';
import { APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { dynamoDbScanTable } from './aws';

// env
const TABLE_NAME = process.env.AWS_TABLE_NAME ?? '';

export const handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
    console.log('stringed event');
    console.log(JSON.stringify(event));

    console.log('scanning table')

    const pageLimit = event.queryStringParameters?.limit ?? 25
    const lastEvaluatedKey = event.queryStringParameters?.lastEvaluatedKey ? marshall(JSON.parse(event.queryStringParameters?.lastEvaluatedKey)) : undefined;
    console.log('last evaluated key', lastEvaluatedKey);
    const scanTableGen = await dynamoDbScanTable(TABLE_NAME, Number(pageLimit), lastEvaluatedKey);
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

    if (iterator.value) {
        return {
            statusCode: 200,
            body: JSON.stringify({
                Items: iterator.value.Items,
                count: iterator.value.Count,
                lastEvaluatedKey: iterator.value.LastEvaluatedKey ? unmarshall(iterator.value.LastEvaluatedKey) : null
            }),
        };
    }
    return {
        statusCode: 500,
        body: JSON.stringify({
            error: 'No value returned'
        }),
    };
};
