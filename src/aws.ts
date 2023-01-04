// DEPENDENCIES
import AWS from 'aws-sdk';
import { marshall, unmarshall } from "@aws-sdk/util-dynamodb"; // It sets objects to aws dynamodb standard and un sets it

AWS.config.update({region: process.env.AWS_REGION_NAME});

const { DynamoDB, SQS } = AWS;

const dynamodb = new DynamoDB();
const sqs = new SQS();

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

// Scan entire table
// Option this time to handle pagination
export const dynamoDbScanTable = async function* (tableName: string, limit: number = 25, lastEvaluatedKey?: AWS.DynamoDB.Key) {
    while (true) {
        const params: AWS.DynamoDB.ScanInput = {
            "TableName": tableName,
            "Limit": limit,
        };

        if (lastEvaluatedKey) {
            params.ExclusiveStartKey = lastEvaluatedKey;
        }

        try {
            const result = await dynamodb.scan(params).promise();
            if (!result.Count) {
                return;
            }

            lastEvaluatedKey = (result as AWS.DynamoDB.ScanOutput).LastEvaluatedKey;

            result.Items = result.Items?.map((item) => unmarshall(item)); // Unmarshall items

            yield result;
        } catch(e) {
            // We will return either an error, or throw one if we don't know what type it is
            if (e instanceof Error) {
                return e
            }
            return new Error(`dynamoDbScanTable unexpected error`);
        }
    }
}

// Puts all items into an object (note if scalability is an issue we would limit results, and call this over multiple processes)
// Not the case here so no need to get too complicated just get it all
// Pagination might be in a future video, you can set it up yourself my reading docs or other tutorial videos
export const getAllScanResults = async <T>(tableName: string, limit: number = 2) => {
    try {
        const scanTableGen = await dynamoDbScanTable(tableName, limit);
        const results: T[] = [];
        let isDone = false;
    
        while(!isDone) {
            const iterator = await scanTableGen.next();

            if (!iterator) {
                throw new Error('No iterator returned')
            }
    
            if (iterator.done || !iterator.value.LastEvaluatedKey) {
                isDone = true;
            }
    
            if (iterator.value) {
                iterator.value.Items!.map((result:any) => results.push(result))
            }
        }
    
        return results;
    } catch(e) {
        if (e instanceof Error) {
            throw e
        }

        throw new Error(`getAllScanResults unexpected error`);
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
        const { connectionId } = connection;
        try {
            await apiGatewayManagementApi.postToConnection({ ConnectionId: connectionId, Data: message }).promise();
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
        const res = await Promise.all(sendVendorsCall);
        return res;
    } catch (e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`broadcastMessageWebsocket error object unknown type`);   
    }
}

// Delete message
export const sqsDeleteMessage = async (queueUrl: string, receiptHandle: string) => {
    try {
        const params: AWS.SQS.DeleteMessageRequest = {
            ReceiptHandle: receiptHandle,
            QueueUrl: queueUrl,
        }

        const result = await sqs.deleteMessage(params).promise();
        console.log('Message deleted!');
        return result;
    } catch(e) {
        if (e instanceof Error) {
            return e
        }
        return new Error(`sqsDeleteMessage error object unknown type`);
    }
}
