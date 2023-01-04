import { marshall, unmarshall } from '@aws-sdk/util-dynamodb';
import { APIGatewayEvent, APIGatewayProxyResult } from 'aws-lambda';
import { AWSError, DynamoDB } from 'aws-sdk';
import { PromiseResult } from 'aws-sdk/lib/request';
import { dynamoDbScanTable } from './aws';

// env
const TABLE_NAME = process.env.AWS_TABLE_NAME ?? '';

export const handler = async (event: APIGatewayEvent): Promise<APIGatewayProxyResult> => {
    const pageLimit = event.queryStringParameters?.limit ?? 25
    const lastEvaluatedKey = event.queryStringParameters?.lastEvaluatedKey ? marshall(JSON.parse(event.queryStringParameters?.lastEvaluatedKey)) : undefined;

    console.log('scanning table')

    let scanTableGen: AsyncGenerator<PromiseResult<DynamoDB.ScanOutput, AWSError>, void, unknown> | undefined;
    try {
        scanTableGen = await dynamoDbScanTable(TABLE_NAME, Number(pageLimit), lastEvaluatedKey);
    } catch (e) {
        if (scanTableGen instanceof Error) {
            console.log('error', scanTableGen.message)
            return {
                statusCode : 500,
                headers: {
                    "content-type": "text/plain; charset=utf-8",
                    "Access-Control-Allow-Headers" : "Content-Type",
                    "Access-Control-Allow-Origin": "*",
                    "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
                },
                body : scanTableGen.message
            }
        }
    }


    const iterator = await scanTableGen?.next();

    if (iterator?.value) {
        return {
            statusCode: 200,
            headers: {
                "Access-Control-Allow-Headers" : "Content-Type",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
            },
            body: JSON.stringify({
                Items: iterator.value.Items,
                count: iterator.value.Count,
                lastEvaluatedKey: iterator.value.LastEvaluatedKey ? unmarshall(iterator.value.LastEvaluatedKey) : null
            }),
        };
    }
    return {
        statusCode: 500,
        headers: {
            "Access-Control-Allow-Headers" : "Content-Type",
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
        },
        body: JSON.stringify({
            error: 'No value returned'
        }),
    };
};
