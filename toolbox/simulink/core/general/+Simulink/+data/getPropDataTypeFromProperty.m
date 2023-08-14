function retVal=getPropDataTypeFromProperty(obj,propName)





    hProp=findprop(obj,propName);

    assert(isscalar(hProp));
    assert(isa(hProp,'Simulink.data.MetaPropertyWithPropertyType'));

    switch hProp.PropertyType
    case ''
        retVal='MATLAB array';
    case 'double scalar'
        retVal='double';
    case 'int32 scalar'
        retVal='int32';
    case 'logical scalar'
        retVal='bool';
    case 'char'
        if~isempty(getPropAllowedValues(obj,propName))
            retVal='enum';
        else
            retVal='string';
        end
    otherwise
        assert(false,'Unexpected property type');
    end


