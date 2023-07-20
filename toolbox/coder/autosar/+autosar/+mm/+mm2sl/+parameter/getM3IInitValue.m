function m3iInitValue=getM3IInitValue(m3iData,m3iDataContainer,m3iConnectedPortFinder,m3iImpType)









    m3iInitValue=getM3iInitValueFromComSpec(m3iData,m3iDataContainer,m3iConnectedPortFinder);

    if isempty(m3iInitValue)
        m3iInitValue=getM3iInitValueFromDataPrototype(m3iData);
    end

    m3iInitValue=updateM3iInitValueType(m3iInitValue,m3iData,m3iImpType);

    if~isCompatibleM3iInitValueType(m3iInitValue)
        m3iInitValue=[];
    end
end

function m3iInitValue=getM3iInitValueFromComSpec(m3iData,m3iDataContainer,m3iConnectedPortFinder)
    m3iInitValue=[];
    if isa(m3iDataContainer,'Simulink.metamodel.arplatform.port.Port')
        m3iInitValue=autosar.mm.mm2sl.utils.getM3iInitValueFromPort(m3iDataContainer,m3iData);
        if slfeature('AUTOSARPPortInitValue')&&isempty(m3iInitValue)&&...
            isa(m3iDataContainer,'Simulink.metamodel.arplatform.port.ParameterReceiverPort')
            m3iPPort=m3iConnectedPortFinder.findParameterPPort(m3iDataContainer);
            if~isempty(m3iPPort)
                m3iInitValue=autosar.mm.mm2sl.utils.getM3iInitValueFromPort(m3iPPort,...
                m3iData);
            end
        end
    end
end

function m3iInitValue=getM3iInitValueFromDataPrototype(m3iData)
    m3iInitValue=[];
    if m3iData.DefaultValue.isvalid()

        m3iInitValue=m3iData.DefaultValue;
    elseif m3iData.InitValue.isvalid()
        m3iInitValue=m3iData.InitValue;
    end
end

function m3iInitValue=updateM3iInitValueType(m3iInitValue,m3iData,m3iImpType)



    if isempty(m3iInitValue)
        return;
    end

    if~m3iInitValue.Type.isvalid()

        m3iInitValue.Type=m3iData.Type;
    end

    if isa(m3iInitValue.Type,'Simulink.metamodel.types.SharedAxisType')
        m3iInitValue=updateM3iInitValueSharedAxisType(m3iInitValue);
    elseif isa(m3iInitValue.Type,'Simulink.metamodel.types.LookupTableType')
        m3iInitValue=updateM3iInitValueLookupTableType(m3iInitValue,m3iImpType);
    end
end

function m3iInitValue=updateM3iInitValueSharedAxisType(m3iInitValue)



    if isa(m3iInitValue,'Simulink.metamodel.types.ConstantReference')
        type=m3iInitValue.Type;
        m3iInitValue=m3iInitValue.Value.ConstantValue;
        m3iInitValue.Type=type;
    end

    if~isa(m3iInitValue,'Simulink.metamodel.types.StructureValueSpecification')
        return;
    end

    for slotIndex=1:m3iInitValue.OwnedSlot.size()
        m3iStructElemValue=m3iInitValue.OwnedSlot.at(slotIndex).Value;
        if isa(m3iStructElemValue,'Simulink.metamodel.types.MatrixValueSpecification')...
            ||isa(m3iStructElemValue,'Simulink.metamodel.types.ApplicationValueSpecification')
            type=m3iInitValue.Type;
            m3iInitValue=m3iStructElemValue;
            m3iInitValue.Type=type;
            return;
        end
    end
end

function m3iInitValue=updateM3iInitValueLookupTableType(m3iInitValue,m3iImpType)


    if isempty(m3iImpType)||~m3iImpType.isvalid()
        return;
    end

    if isa(m3iInitValue,'Simulink.metamodel.types.ConstantReference')
        assert(m3iInitValue.Value.isvalid()&&m3iInitValue.Value.ConstantValue.isvalid(),...
        'Unexpected invalid constant reference specification');
        m3iConst=m3iInitValue.Value.ConstantValue;
    else
        m3iConst=m3iInitValue;
    end

    if isa(m3iConst,'Simulink.metamodel.types.LookupTableSpecification')
        return;
    end

    if(isa(m3iImpType,'Simulink.metamodel.types.Matrix')||...
        (slfeature('AUTOSARLUTRecordValueSpec')&&...
        isa(m3iImpType,'Simulink.metamodel.types.Structure')))
        m3iInitValue.Type=m3iImpType;
    end
end

function isCompatible=isCompatibleM3iInitValueType(m3iInitValue)
    if isa(m3iInitValue,'Simulink.metamodel.types.MatrixValueSpecification')
        isCompatible=isa(m3iInitValue.Type,'Simulink.metamodel.types.Matrix')||...
        isa(m3iInitValue.Type,'Simulink.metamodel.types.LookupTableType')||...
        isa(m3iInitValue.Type,'Simulink.metamodel.types.SharedAxisType');
    else
        isCompatible=true;
    end
end


