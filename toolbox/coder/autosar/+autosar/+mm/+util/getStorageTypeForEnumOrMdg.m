function matlabStorageType=getStorageTypeForEnumOrMdg(m3iType,m3iImpType)















    narginchk(2,2);

    switch(class(m3iType))
    case 'Simulink.metamodel.types.Enumeration'
        tag='enumeration';
    case 'Simulink.metamodel.arplatform.common.ModeDeclarationGroup'
        tag='mode declaration group';
    otherwise
        assert(false,'Unsupported m3iType class: %s.',class(m3iType));
    end

    if~isempty(m3iImpType)
        autosar.mm.util.validateM3iArg(m3iImpType,'Simulink.metamodel.foundation.ValueType');
        matlabStorageType=autosar.mm.util.getStorageTypeFromImpDataType(tag,m3iType.Name,m3iImpType);
    elseif isa(m3iType,'Simulink.metamodel.arplatform.common.ModeDeclarationGroup')



        matlabStorageType='uint8';
        for ii=1:m3iType.Mode.size()
            if~isempty(m3iType.Mode.at(ii).Value)
                if m3iType.Mode.at(ii).Value>intmax('uint8')...
                    &&m3iType.Mode.at(ii).Value<=intmax('uint16')
                    matlabStorageType='uint16';
                elseif m3iType.Mode.at(ii).Value>intmax('uint16')
                    matlabStorageType='int32';
                end
            end
        end
    else

        autosar.mm.util.validateM3iArg(m3iType,'Simulink.metamodel.foundation.ValueType');
        matlabStorageType=autosar.mm.util.getStorageTypeFromImpDataType(tag,m3iType.Name,m3iType);
    end


