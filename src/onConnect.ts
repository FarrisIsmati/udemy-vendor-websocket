import { Context, APIGatewayProxyResult, SQSEvent } from 'aws-lambda';

export const lambdaHandler = async (event: SQSEvent, context: Context): Promise<APIGatewayProxyResult> => {
    console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    console.log(`Context: ${JSON.stringify(context, null, 2)}`);

    // var putParams = {
    //   TableName: process.env.TABLE_NAME,
    //   Item: {
    //     connectionId: { S: event.requestContext.connectionId }
    //   }
    // };
  
    // DDB.putItem(putParams, function(err, data) {
    //   callback(null, {
    //     statusCode: err ? 500 : 200,
    //     body: err ? "Failed to connect: " + JSON.stringify(err) : "Connected"
    //   });
    // });

    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'hello world',
        }),
    };
  };