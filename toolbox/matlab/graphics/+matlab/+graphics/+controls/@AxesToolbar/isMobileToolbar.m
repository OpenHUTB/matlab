
function result=isMobileToolbar(obj)

    if isempty(obj.isMobile)
        clientType=connector.internal.getClientType();
        obj.isMobile=startsWith(clientType,'mobile');
    end

    result=obj.isMobile;
end

