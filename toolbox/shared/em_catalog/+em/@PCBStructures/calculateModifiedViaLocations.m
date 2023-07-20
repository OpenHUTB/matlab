function modifiedvialocs=calculateModifiedViaLocations(obj)
    fullLayerMap=obj.ViaLocations(:,3:4);
    truelayermap=calculateTrueLayerMappings(obj,fullLayerMap);
    modifiedvialocs=[obj.ViaLocations(:,1:2),truelayermap];
end