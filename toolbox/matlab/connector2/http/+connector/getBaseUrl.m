function url=getBaseUrl(path)
    if nargin==0||numel(path)==0
        path='/';
    elseif path(1)~='/'
        path=['/',path];
    end
    connector.ensureServiceOn;

    contextRoot=connector.internal.getConfig('contextRoot');

    if(~isempty(contextRoot))
        url=sprintf('https://127.0.0.1:%d%s%s',connector.securePort,contextRoot,path);
    else
        url=sprintf('https://127.0.0.1:%d%s',connector.securePort,path);
    end
end
