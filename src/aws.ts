// DEPENDENCIES
import AWS from 'aws-sdk';
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb"; // It sets objects to aws dynamodb standard and un sets it

AWS.config.update({region: process.env.AWS_REGION_NAME});

const { DynamoDB, ApiGatewayManagementApi } = AWS;

const dynamodb = new DynamoDB();

// Add connection to db
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

// Remove connection from db
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

// Scan entire table for all connection ids
export const dynamoDbScanTable = async (tableName: string) => {
    const params: AWS.DynamoDB.ScanInput = {
        "TableName": tableName,
        "ProjectionExpression": 'connectionId'
    };

    try {
        const result = await dynamodb.scan(params).promise();
        if (!result.Count) {
            return new Error(`dynamoDbScanTable yielded no results`);
        }

        result.Items = result.Items?.map((item) => unmarshall(item)); // Unmarshall items
        return result
    } catch(e) {
        // We will return either an error, or throw one if we don't know what type it is
        if (e instanceof Error) {
            return e
        }
        return new Error(`dynamoDbScanTable unexpected error`);
    }
}

interface BroadcastMessageWebsocketProps {
    apiGatewayManagementApi: AWS.ApiGatewayManagementApi, 
    connections: any[], 
    message: string,
    tableName: string,
}

// Broadcast message
export const broadcastMessageWebsocket = async (props: BroadcastMessageWebsocketProps) => {
    const { apiGatewayManagementApi, connections, message, tableName } = props;
    const sendVendorsCall = connections?.map(async connection => {
        const {connectionId} = connection;
        try {
            const res = await apiGatewayManagementApi.postToConnection({ ConnectionId: connectionId, Data: message }).promise();
            return res;
        } catch (e) { 
            // Cannot get the type for this in the AWS SDK v2
            if ((e as any).statusCode === 410) {
                console.log(`delete stale connection: ${connectionId}`);
                const removeConnRes = await dynamoDbRemoveConnection(tableName, connectionId);
                if (removeConnRes instanceof Error) {
                    return e;
                }
            } else {
                return e;
            }

        }
    })

    try {
        return await Promise.all(sendVendorsCall);
    } catch (e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`broadcastMessageWebsocket error object unknown type`);   
    }
}
