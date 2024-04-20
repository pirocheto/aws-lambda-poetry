import requests


def lambda_handler(event, context):
    """Lambda function to retrieve a random joke of a specified type."""

    joke_type = event["type"]

    # Call the API to retrieve a joke
    response = requests.get(
        f"https://official-joke-api.appspot.com/jokes/{joke_type}/random"
    )

    # Check the API response
    if response.status_code == 200:
        joke = response.json()
        return {"statusCode": 200, "body": joke}
    else:
        return {"statusCode": response.status_code, "body": "Error retrieving the joke"}
