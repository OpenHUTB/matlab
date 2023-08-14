



function newPropValue=massageAndValidatePerInstancePropertyValue(...
    modelH,mappingObj,propName,propValue)
    newPropValue=propValue;

    obj=mappingObj.MappedTo;
    if isempty(obj)||~isa(obj,'Simulink.DataReferenceClass')
        return;
    end

    propType=obj.getCSCAttributeType(modelH,propName);
    switch propType
    case{'int32','double'}
        if~islogical(propValue)&&~isnumeric(propValue)
            DAStudio.error('coderdictionary:api:InvalidPropertyType',...
            propName,'numeric or logical')
        end
        newPropValue=cast(propValue,propType);
    case 'bool'



        allowSpecialCase=isequal(propName,'PreserveDimensions')...
        &&ischar(propValue)&&...
        (isequal(propValue,'0')||isequal(propValue,'1'));
        if allowSpecialCase

            if isequal(propValue,'0')
                newPropValue=false;
            else
                newPropValue=true;
            end
            return;
        end
        if~islogical(propValue)&&~isnumeric(propValue)
            DAStudio.error('coderdictionary:api:InvalidPropertyType',...
            propName,'logical or numeric')
        end
        newPropValue=cast(propValue,'logical');
    case 'string'
        if~ischar(propValue)&&~isStringScalar(propValue)
            DAStudio.error('coderdictionary:api:InvalidPropertyType',...
            propName,'character array')
        end
    case 'enum'







        allowSpecialCase=isequal(propName,'MemorySection')...
        &&ischar(propValue)&&...
        isequal(propValue,'Default');
        if allowSpecialCase


            newPropValue='None';
            return;
        end

        allowedValues=obj.getCSCAttributeAllowedValues(modelH,propName);
        if~ischar(propValue)||~any(strcmp(propValue,allowedValues))
            DAStudio.error('coderdictionary:api:InvalidPropertyTypeWithAllowedList',...
            propName,'character array',...
            strjoin(obj.getCSCAttributeAllowedValues(modelH,propName),', '))
        end
    otherwise


    end
end
