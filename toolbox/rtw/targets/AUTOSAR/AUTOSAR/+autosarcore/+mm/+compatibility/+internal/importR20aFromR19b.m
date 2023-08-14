function importR20aFromR19b(transformer)





    function m3iModel=postModelTransform(m3iModel)
        exportMachineStatesInMachineManifest(m3iModel);


        renameInitValueExternalToolInfo(m3iModel);
    end
    transformer.setPostModelTransform(@postModelTransform);
end

function exportMachineStatesInMachineManifest(m3iModel)



    modeDeclpkg=autosarcore.MetaModelFinder.getArPackage(m3iModel,'MachineStates');
    if~isempty(modeDeclpkg)
        if~isempty(modeDeclpkg.packagedElement)
            for ii=1:modeDeclpkg.packagedElement.size()
                if strcmp(modeDeclpkg.packagedElement.at(ii).Name,'DefaultMachineStates')
                    autosar.internal.adaptive.manifest.ManifestUtilities.markElementAsManifestARXML(modeDeclpkg.packagedElement.at(ii));
                    break;
                end
            end
        end
    end
end

function renameInitValueExternalToolInfo(m3iModel)




    m3iComSpecSeq=Simulink.metamodel.arplatform.ModelFinder.findObjectByParentMetaClass(m3iModel,...
    Simulink.metamodel.arplatform.port.PortComSpec.MetaClass,true);

    for idx=1:m3iComSpecSeq.size()
        m3iComSpec=m3iComSpecSeq.at(idx);
        m3iInfo=m3iComSpec.containerM3I;
        m3iPort=m3iInfo.containerM3I;
        if m3iPort.isvalid()&&m3iInfo.isvalid()&&...
            m3iInfo.has('DataElements')&&m3iInfo.DataElements.isvalid()
            toolId=[m3iPort.Name,'_',m3iInfo.DataElements.Name...
            ,'_InitValue'];
        else
            continue;
        end
        userValue=m3iComSpec.getExternalToolInfo(toolId).externalId;
        if isempty(userValue)
            continue;
        else

            autosar.ui.comspec.ComSpecPropertyHandler.setInitValue(m3iComSpec,userValue);

            m3iComSpec.setExternalToolInfo(M3I.ExternalToolInfo(toolId,''));
        end
    end
end


