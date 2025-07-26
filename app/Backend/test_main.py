import pytest
from unittest.mock import patch, MagicMock
from app.Backend.main import hello_http

class MockRequest:
    def __init__(self, method):
        self.method = method

@patch("app.Backend.main.firestore")
def test_get_request(mock_firestore):
    # Mock Firestore document get
    mock_doc = MagicMock()
    mock_doc.get.return_value.to_dict.return_value = {"visitor-number": 42}
    mock_firestore.client.return_value.collection.return_value.document.return_value = mock_doc

    request = MockRequest("GET")
    response = hello_http(request)
    assert response[1] == 200
    assert "Visitor_Count" in response[0]
    assert "Visitor count received" in response[0]

@patch("app.Backend.main.firestore")
def test_post_request(mock_firestore):
    # Mock Firestore document get and update
    mock_doc = MagicMock()
    mock_doc.get.return_value.to_dict.return_value = {"Vistor_Counter": 42} # the field name of the database
    mock_doc.update.return_value = True
    mock_firestore.client.return_value.collection.return_value.document.return_value = mock_doc

    request = MockRequest("POST")
    response = hello_http(request)
    assert response[1] == 200
    assert "Visitor_Count" in response[0]
    assert "Visitor count Updated" in response[0]

def test_options_request():
    request = MockRequest("OPTIONS")
    response = hello_http(request)
    assert response[1] == 204

def test_unsupported_method():
    request = MockRequest("DELETE")
    response = hello_http(request)
    assert response[1] == 405
    assert "Method not allowed" in response[0]