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
            throw new Error(`dynamoDbScanTable yielded no results`);
        }

        result.Items = result.Items?.map((item) => unmarshall(item)); // Unmarshall items
        return result
    } catch(e) {
        // We will return either an error, or throw one if we don't know what type it is
        if (e instanceof Error) {
            throw e
        }
        throw new Error(`dynamoDbScanTable unexpected error`);
    }
}

// Send message
export const sendMessageWebsocket = async (apiGatewayManagementApi: AWS.ApiGatewayManagementApi, items: any[]) => {

    await apiGatewayManagementApi.postToConnection()
}
// Delete calls if they are stale connection
// const postCalls = connectionData.Items.map(async ({ CONNECTION_ID }) => {
//     let connectionId = CONNECTION_ID;
//     console.log("connectionId " + connectionId);
//     try {
//       await apigwManagementApi.postToConnection({ ConnectionId: connectionId, Data: postData }).promise();
//     } catch (e) {
//       if (e.statusCode === 410) {
//         console.log(`Found stale connection, deleting ${connectionId}`);
//         await ddb.delete({ TableName: TABLE_NAME, Key: { connectionId } }).promise();
//       } else {
//         throw e;
//       }
//     }
//   });