from mock import MagicMock
import pytest
from requests.exceptions import RequestException

from request_factory import HTTPErrorCode
from request_factory import http_request_factory
from request_factory import retry_http


def test_retry_http(mocker):
    mock_sleep = mocker.patch('time.sleep')
    global counter
    counter = 0

    @retry_http
    def f():
        global counter
        counter += 1
        if counter == 1:
            raise HTTPErrorCode('msg')
        elif counter == 2:
            raise RequestException()
        else:
            raise ValueError

    with pytest.raises(ValueError):
        f()
    assert counter == 3
    assert len(mock_sleep.call_args_list) == 2


@pytest.mark.parametrize('status_code', [200, 204])
@pytest.mark.parametrize('text', ["{'titi': 'oto'}", ""])
def test_request_factory(mocker, status_code, text):
    response = MagicMock(status_code=status_code, text=text)
    mocker.patch('requests.get', return_value=response)
    mocker.patch('requests.post', return_value=response)
    mocker.patch('requests.put', return_value=response)
    mocker.patch('requests.delete', return_value=response)

    host = 'host'
    endpoint = 'endpoint'
    http_request_factory(host, 'GET', endpoint)
    http_request_factory(host, 'POST', endpoint)
    http_request_factory(host, 'PUT', endpoint)
    http_request_factory(host, 'DELETE', endpoint)


def test_none_on_404(mocker):
    response = MagicMock(status_code=404)
    mocker.patch('time.sleep')
    mocker.patch('requests.get', return_value=response)
    host = 'host'
    endpoint = 'endpoint'
    with pytest.raises(HTTPErrorCode):
        http_request_factory(host, 'GET', endpoint, return_none_on_404=False)

    assert http_request_factory(host, 'GET', endpoint, return_none_on_404=True) is None


def test_unknown_http_word(mocker):
        mocker.patch('time.sleep')
        host = 'host'
        endpoint = 'endpoint'
        response = {'request_factory': 'Unknown request type: AWESOME_HTTP_WORD'}
        with pytest.raises(HTTPErrorCode):
            assert http_request_factory(host, 'AWESOME_HTTP_WORD', endpoint, return_none_on_404=False) == response
