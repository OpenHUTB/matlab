function ret=signal_object_properties(action,lineObj,prop)



    if strcmp(action,'subProperties')
        ret=signal_object_subProperties(lineObj,prop);
    elseif strcmp(action,'propertyValue')
        ret=signal_object_propertyValue(lineObj,prop);
    elseif strcmp(action,'propertyRenderMode')
        ret=signal_object_propertyRenderMode(lineObj,prop);
    elseif strcmp(action,'isPropertyEnabled')
        ret=signal_object_isPropertyEnabled(lineObj,prop);
    end
end

