function future=configurationAddPropertyFileSource(name,group,order,readOnly,path)
    msg=struct('type','connector/configuration/AddPropertyFileSource',...
    'name',name,'group',group,'order',order,'readOnly',readOnly,'path',path);

    future=connector.internal.synchronousNativeBridgeServiceProviderDeliver(msg,...
    {'connector/json/deserialize','connector/configuration'});
end
