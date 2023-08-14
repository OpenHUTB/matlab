function entitledProducts=getEntitledProducts()

    connector.ensureServiceOn;


    msg=struct('type','connector/v1/GetCurrentEntitledProducts');
    result=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
    {'connector/json/deserialize','connector/v1/worker'}).get();

    entitledProducts=result.entitledProducts;
end