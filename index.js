// Load the AWS SDK for Node.js
const AWS = require('aws-sdk');

// Set the region (make sure it matches the region of your SNS topic)
AWS.config.update({ region: 'ap-southeast-2' });

// Create an SNS service object
const sns = new AWS.SNS();

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
  // const message = 'This is a log message from Lambda!';
  // console.log(message);

  // go to db
  // add logic to see what users to be notified
  // Mock some user data, then we can proceed the rest of the logic

  const notificiations = [
    {
      title: 'appointment reminder - 1',
      description: 'please go to the appointment tomorrow morning',
      template:
        'Dear #{firstName}, Please go to the appointment tomorrow morning',
      user: {
        firstName: 'John',
        lastName: 'Doe',
        email: 'John.Doe@yahoo.com.au',
      },
    },
    {
      title: 'appointment reminder - 2',
      description: 'please go to the appointment tomorrow lunch time',
    },
  ];

  // created sns
  // connect sns

  // Function to publish a message to an SNS topic
  const publishMessage = async (message, topicArn) => {
    const params = {
      Message: message, // The message to send
      TopicArn: topicArn, // The ARN of the SNS topic
    };

    try {
      const data = await sns.publish(params).promise();
      console.log(
        `Message ${params.Message} sent to the topic ${params.TopicArn}`
      );
      console.log('MessageID is ' + data.MessageId);
      return data;
    } catch (err) {
      console.error(err, err.stack);
      return err;
    }
  };

  // Replace with your SNS topic ARN
  const topicArn = 'arn:aws:sns:ap-southeast-2:471112501320:my_sns_topic';

  // Replace with the message you want to send
  const message = 'Hello, this is a test message';

  // Publish the message
  const publishResult = await publishMessage(message, topicArn);

  console.log(publishResult);

  // get email/ text template /    combine with users personal info
  // message  ====> email  / text

  // return successfule message

  // error

  // Return a response
  const response = {
    statusCode: 200,
    body: JSON.stringify(publishResult),
  };
  return response;
};
