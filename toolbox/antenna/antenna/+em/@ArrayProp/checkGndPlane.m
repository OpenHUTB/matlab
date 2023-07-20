function gndPlaneDim=checkGndPlane(obj)



    publicVisibleProperties=getPropertyGroups(obj.Element);
    addPropertyList=fields(publicVisibleProperties.PropertyList);
    checkProperties=strcmpi(addPropertyList,'GroundPlaneRadius');
    gndPlaneDim=setDynamicProperties(obj,checkProperties);
end