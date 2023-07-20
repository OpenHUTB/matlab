function result=openImpl(reporter,impl,varargin)
    if isempty(varargin)
        key=['E2C548z0ABVPjL9jqtmJrEo5FkazP9ARLKMrsJGl+UY+ZhBZ+S0pDqaV04FE'...
        ,'JHeB3OD5aBdWk2CrpMALz8MF/r/d4nOGIZXPuOaAsMWm2dZ5W8TVlXKYtS53'...
        ,'vzzR20Gqy6w6iItjVVaWmK+aM4V8g9KO1O/B0klALlRopQmeU6btKHDS+3SQ'...
        ,'QgsW1gWidbMKuQ2c6vSd9s2UahM='];
    else
        key=varargin{1};
    end
    result=open(impl,key,reporter);
end