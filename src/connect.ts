import { Context, APIGatewayProxyResult, APIGatewayEvent } from 'aws-lambda';

export const handler = async (event: APIGatewayEvent, context: Context): Promise<APIGatewayProxyResult> => {
    // console.log(`Event: ${JSON.stringify(event, null, 2)}`);
    // console.log(`Context: ${JSON.stringify(context, null, 2)}`);
    // const putParams = {
    //     TableName: process.env.TABLE_NAME,
    //     Item: {
    //       connectionId: { S: event.requestContext.connectionId }
    //     }
    // };
    
    // DDB.putItem(putParams, function(err, data) {
    //     callback(null, {
    //       statusCode: err ? 500 : 200,
    //       body: err ? "Failed to connect: " + JSON.stringify(err) : "Connected"
    //     });
    //   });

      
    return {
        statusCode: 200,
        body: JSON.stringify({
            message: 'connect!',
        }),
    };

//  {
//      "statusCode" : 500,
//          "headers" : {
//            "content-type": "text/plain; charset=utf-8"
//          },
//          "body" : "Some error fetching the content"
//        }
//   }
};
