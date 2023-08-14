function result=ConvertSlidToSlObject(slidObject)








    switch class(slidObject)
    case 'slid.StructureType'
        result=ConvertStructureTypeToSlObject(slidObject);
    case 'slid.FloatingPointType'
        result=ConvertFloatingPointTypeToSlObject(slidObject);
    case 'slid.FixedPointType'
        result=ConvertFixedPointTypeToSlObject(slidObject);
    case 'slid.IntegerType'
        result=ConvertFixedPointTypeToSlObject(slidObject);
    case 'slid.BooleanType'
        result=ConvertBooleanTypeToSlObject(slidObject);
    case 'slid.AliasType'
        result=ConvertAliasTypeToSlObject(slidObject);
    otherwise

        error("Type not supported for conversion to Simulink");
    end
end



function result=ConvertStructureTypeToSlObject(slidObject)


    result=Simulink.Bus;
    result.Description=slidObject.Description;
    structElements=slidObject.Element.toArray;
    busElements=Simulink.BusElement.empty;


    for m=1:length(structElements)
        structElement=structElements(m);
        structElementType=structElement.Type;
        assert(~isOpaqueType(structElementType));
        if(isNumericType(structElementType)||isAliasType(structElementType)||isStructureType(structElementType))
            busElement=Simulink.BusElement;
            busElementName=structElement.Name;
            busElement.Name=busElementName;
            busElement=populateBusElementFromStructElement(busElement,structElement);
            busElements=[busElements,busElement];%#ok<AGROW>
        end
    end

    result.Elements=busElements;
end

function result=ConvertBooleanTypeToSlObject(slidObject)


    result=Simulink.NumericType;
    result.Description=slidObject.Description;
    typeStr=slidObject.TypeIdentifier;

    if(strcmpi(typeStr,'boolean'))
        result.DataTypeMode='Boolean';
    else

        error("Invalid Type Identifier for boolean type");
    end
end

function result=ConvertFloatingPointTypeToSlObject(slidObject)


    result=Simulink.NumericType;
    result.Description=slidObject.Description;
    typeStr=slidObject.TypeIdentifier;

    if(strcmpi(typeStr,'single'))
        result.DataTypeMode='Single';
    elseif(strcmpi(typeStr,'double'))
        result.DataTypeMode='Double';
    else

        error("Invalid Type Identifier for floating point type");
    end
end

function result=ConvertFixedPointTypeToSlObject(slidObject)


    container=parseDataType(slidObject.TypeIdentifier);

    if(isempty(container.ResolvedType))
        error("Invalid Type Identifier for fixed point type");
    end

    result=container.ResolvedType;
    result.Description=slidObject.Description;
end

function result=ConvertAliasTypeToSlObject(slidObject)


    result=Simulink.AliasType;
    result.Description=slidObject.Description;
    baseType=slidObject.BaseType;

    if(isAliasType(baseType)||isNumericType(baseType))
        result.BaseType=baseType.Name;
    else

        error("base type not supported for conversion to simulink for alias type");
    end
end






function busElement=populateBusElementFromStructElement(busElement,structElement)



    busElement.Name=structElement.Name;
    structElementType=structElement.Type;

    if(isprop(structElementType,'TypeIdentifier')&&~isempty(structElementType.TypeIdentifier))
        busElement.DataType=structElementType.TypeIdentifier;
    else
        busElement.DataType=structElementType.Name;
    end

    if(isNumericType(structElementType))

        busElement.Description=structElement.Description;

        if(isempty(structElement.Dimensions))
            busElement.Dimensions=[];
        else
            busElement.Dimensions=structElement.Dimensions;
        end

        busElement.Min=structElementType.Minimum;
        busElement.Max=structElementType.Maximum;

        if(structElement.Type.Complexity==slid.ComplexityKind.COMPLEX)
            busElement.Complexity='complex';
        else
            busElement.Complexity='real';
        end

        busElement.Unit=structElementType.UnitExpression;
    end

end

function result=isNumericType(slidObject)


    result=isa(slidObject,'slid.FloatingPointType')||...
    isa(slidObject,'slid.FixedPointType')||...
    isa(slidObject,'slid.IntegerType')||...
    isa(slidObject,'slid.BooleanType');
end

function result=isAliasType(slidObject)

    result=isa(slidObject,'slid.AliasType');
end

function result=isStructureType(slidObject)

    result=isa(slidObject,'slid.StructureType');
end

function result=isOpaqueType(slidObject)

    result=isa(slidObject,'slid.OpaqueType');
end
