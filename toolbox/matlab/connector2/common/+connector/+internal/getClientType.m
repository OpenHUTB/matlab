function clientType=getClientType

    try

        prop=connector.internal.getClientTypeProperties();
        clientType=prop.TYPE;

    catch ex
        clientType='';
    end