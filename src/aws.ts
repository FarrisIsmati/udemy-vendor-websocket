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
                primaryKey: marshall({connectionId: connectionId}),
            }
        };

        // Call DynamoDB to add connection
        const result = await dynamodb.deleteItem(params).promise();

        return result;
    } catch(e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`dynamoDbRemoveConnection error object unknown type`);
    }
}
