


function url=getFevalUrl(functionName,queryParameters)
    url=['http://127.0.0.1:31415/matlab/feval/',functionName];
    if nargin==2&&numel(queryParameters)>0
        url=[url,'?',queryParameters];
    end
end
