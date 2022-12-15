// DEPENDENCIES
import AWS from 'aws-sdk';
import { marshall } from "@aws-sdk/util-dynamodb"; // It sets objects to aws dynamodb standard and un sets it

AWS.config.update({region: process.env.AWS_REGION_NAME});

const { DynamoDB } = AWS;

const dynamodb = new DynamoDB();

export const dynamoDbAddConnection = async (tableName: string, connectionId: string) => {
    try {
        const params: AWS.DynamoDB.PutItemInput= {
            TableName: tableName,
            Item: marshall({connectionId})
        };

        // Call DynamoDB to add connection
        const result = await dynamodb.putItem(params).promise();

        return result;
    } catch(e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`dynamoDbAddConnection error object unknown type`);
    }
}

export const dynamoDbRemoveConnection = async (tableName: string, connectionId: string) => {
    try {
        const params: AWS.DynamoDB.DeleteItemInput= {
            TableName: tableName,
            Key: {
                'connectionId': marshall(connectionId)
            }
        };
        console.log(params)
        // Call DynamoDB to add connection
        const result = await dynamodb.deleteItem(params).promise();

        return result;
    } catch(e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`dynamoDbAddConnection error object unknown type`);
    }
}

export const dynamoDbDescribeTable = async (tableName: string) => {
    try {
        const table = await dynamodb.describeTable({
            TableName: tableName
        }).promise();
        return table;
    } catch(e) {
        // We will return either an error, or throw one if we don't know what type it is
        if (e instanceof Error) {
            throw e;
        }
        throw new Error(`dynamoDbDescribeTable unexpected error`);
    }
}