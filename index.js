exports.handler = async (event) => {
  // Log the incoming event to CloudWatch
  console.log('Received event:', JSON.stringify(event, null, 2));

  // Extract query string parameters from the event
  const queryStringParameters = event.queryStringParameters;
  console.log(
    'Query String Parameters:',
    JSON.stringify(queryStringParameters, null, 2)
  );

  // Simulate some business logic
  const message = 'This is a log message from Lambda!';
  console.log(message);

  // go to db
  // add logic to see what users to be notice

  // connect sns

  // get email/ text template /    combine with users personal info
  // message  ====> email  / text

  // return successfule message

  // error

  // Return a response
  const response = {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda with logging!'),
  };
  return response;
};
