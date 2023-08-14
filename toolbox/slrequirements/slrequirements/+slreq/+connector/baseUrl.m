function html=baseUrl(method,isSecure)

    if nargin<2
        isSecure=false;
    end

    if isSecure
        protocol='https';
        portNumber='31515';
    else
        protocol='http';
        portNumber='31415';
    end

    html=[protocol,'://127.0.0.1:',portNumber,'/matlab/oslc/',method];
end
