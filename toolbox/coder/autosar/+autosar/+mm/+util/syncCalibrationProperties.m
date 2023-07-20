function syncCalibrationProperties(model,mappingObj,propName)





    calibProps={'SwAddrMethod','DisplayFormat','SwCalibrationAccess'};

    mappingPropValue=mappingObj.MappedTo.getPerInstancePropertyValue(propName);

    m3iDE=autosar.mm.util.findM3iDataElementFromPortParameterMapping(model,mappingObj);

    if isempty(m3iDE)

        return;
    end

    if strcmp(propName,'DataElement')



        for prop=calibProps

            mappingPropValue=mappingObj.MappedTo.getPerInstancePropertyValue(prop{1});
            [needsUpdate,newMappingValue]=...
            i_MetaModelOrMappingNeedsUpdate(m3iDE,prop{1},mappingPropValue);
            if needsUpdate
                Simulink.CodeMapping.setPerInstancePropertyValue(...
                model,mappingObj,'MappedTo',prop{1},newMappingValue);
            end
        end
    elseif any(strcmp(propName,calibProps))


        [needsUpdate,~,newMetaModelValue]=...
        i_MetaModelOrMappingNeedsUpdate(m3iDE,propName,mappingPropValue);
        if needsUpdate
            t=M3I.Transaction(m3iDE.modelM3I);
            m3iDE.(propName)=newMetaModelValue;
            t.commit();
        else

        end

    end
end

function[needsUpdate,newMappingValue,newMetaModelValue]=i_MetaModelOrMappingNeedsUpdate(m3iDE,m3iPropName,mappingPropValue)
    arDictValue=m3iDE.(m3iPropName);
    switch m3iPropName
    case 'SwCalibrationAccess'
        switch mappingPropValue
        case 'ReadWrite'
            mappingPropValue=Simulink.metamodel.foundation.SwCalibrationAccessKind.ReadWrite;
        case 'NotAccessible'
            mappingPropValue=Simulink.metamodel.foundation.SwCalibrationAccessKind.NotAccessible;
        case 'ReadOnly'
            mappingPropValue=Simulink.metamodel.foundation.SwCalibrationAccessKind.ReadOnly;
        otherwise
            assert(false,'Did not expect to get here');
        end
        needsUpdate=(mappingPropValue~=arDictValue);
        newMetaModelValue=mappingPropValue;
        newMappingValue=arDictValue.toString();
    case 'SwAddrMethod'
        if isempty(mappingPropValue)
            newMetaModelValue=Simulink.metamodel.arplatform.common.SwAddrMethod.empty();
            if isempty(arDictValue)
                needsUpdate=false;
                newMappingValue='';
            else
                needsUpdate=true;
                newMappingValue=arDictValue.Name;
            end
        else
            m3iModel=m3iDE.modelM3I;
            m3iSwAddrMethods=autosar.ui.utils.collectObject(m3iModel,...
            autosar.ui.metamodel.PackageString.SwAddrMethodClass);
            needsUpdate=isempty(arDictValue)||~strcmp(mappingPropValue,arDictValue.Name);
            newMetaModelValue=m3iSwAddrMethods(strcmp({m3iSwAddrMethods(:).Name},mappingPropValue));
            assert(length(newMetaModelValue)==1,'Expected to find 1 SwAddrMethod');
            if isempty(arDictValue)
                newMappingValue='';
            else
                newMappingValue=arDictValue.Name;
            end
        end
    case 'DisplayFormat'
        needsUpdate=~strcmp(mappingPropValue,arDictValue);
        newMetaModelValue=mappingPropValue;
        newMappingValue=arDictValue;
    otherwise
        assert(false,'Did not expect to get here');
    end
end


