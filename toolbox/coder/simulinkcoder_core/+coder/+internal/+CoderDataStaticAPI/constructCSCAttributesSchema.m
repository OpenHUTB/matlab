function out=constructCSCAttributesSchema(csc)
    returnArray=[];
    props=csc.propInfo.toArray;
    for i=1:length(props)
        currentProp=props(i);
        if~currentProp.InstanceSpecific
            continue;
        end

        pStruct.Name=currentProp.Name;
        propValue=csc.(currentProp.Name);
        pStruct.Value=char(propValue);
        pStruct.DisplayValue=pStruct.Value;
        pStruct.AllowedValues={};
        if ischar(propValue)
            pStruct.Type='string';
        elseif isenum(propValue)
            pStruct.Type='enum';
            enumArray=enumeration(propValue);
            for j=1:length(enumArray)
                pStruct.AllowedValues{end+1}=char(enumArray(j));
            end
        end
        returnArray=[returnArray,pStruct];%#ok<AGROW>
    end
    out=jsonencode(returnArray);
end
