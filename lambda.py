import boto3

def lambda_handler(event, context):
    client = boto3.client('stepfunctions')
    
    # Specify the state machine ARN
    state_machine_arn = 'arn:aws:states:eu-central-1:000000000000:stateMachine:stepfuntion-state-machine'
    
    # Start the execution of the state machine
    response = client.start_execution(
        stateMachineArn=state_machine_arn,
        input='{}'
    )
    
    # Return the execution ARN for monitoring
    return response['executionArn']

