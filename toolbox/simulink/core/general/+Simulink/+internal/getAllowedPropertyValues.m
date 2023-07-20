function aPropertyValues=getAllowedPropertyValues(aSLObj,aPropertyName)





    aPropertyValues={};

    aSLObj=get_param(aSLObj,'Object');
    if isempty(aSLObj)
        return;
    end

    aPropertyValues=aSLObj.getPropAllowedValues(aPropertyName);
end