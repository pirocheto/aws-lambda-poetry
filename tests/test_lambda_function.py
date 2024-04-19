from src.lambda_function import lambda_handler


def test_lambda_handler_success():
    result = lambda_handler({"type": "programming"}, {})

    # Check the result
    print(result)
    assert result["statusCode"] == 200
    assert len(result["body"]) > 0


def test_lambda_handler_error():
    result = lambda_handler({"type": "non-existent type"}, {})

    # Check the result
    print(result)
    assert result["statusCode"] == 200
    assert len(result["body"]) == 0
