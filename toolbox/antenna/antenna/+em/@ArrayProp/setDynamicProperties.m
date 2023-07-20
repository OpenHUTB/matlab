function gndPlaneDim=setDynamicProperties(obj,checkProperties)

    if any(checkProperties)
        gndPlaneDim=calculateGroundPlaneDefaults(obj,'Circle');
    else
        gndPlaneDim=calculateGroundPlaneDefaults(obj,'Rectangle');
    end
end