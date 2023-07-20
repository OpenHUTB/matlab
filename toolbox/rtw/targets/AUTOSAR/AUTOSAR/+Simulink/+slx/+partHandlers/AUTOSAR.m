function h=AUTOSAR






    h=Simulink.slx.PartHandler('autosar','blockDiagram',@i_load,@i_save);

end

function name=i_partname
    name='/autosar/autosar.xmi';
end

function p=i_autosar_partinfo
    persistent part_info;
    if isempty(part_info)
        content_type='application/vnd.mathworks.simulink.autosar+xml';
        relationship_type=...
        'http://schemas.mathworks.com/simulink/2012/relationships/autosar';
        id='autosar';
        parent='';
        part_info=Simulink.loadsave.SLXPartDefinition(i_partname,parent,content_type,relationship_type,id);
    end
    p=part_info;
end

function i_load(modelHandle,loadOptions)
    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end



    autosarcore.grandfatherAdaptiveSchemaVersion(modelHandle);

    partName=i_partname;
    if~loadOptions.readerHandle.hasPart(partName)
        return;
    end

    xmiFileName=Simulink.slx.getUnpackedFileNameForPart(modelHandle,partName);
    loadOptions.readerHandle.readPartToFile(partName,xmiFileName);

    if~autosarinstalled()
        return;
    end

    autosarcore.ModelUtils.uniquifyMappingName(modelHandle);

    autosarcore.setModelCallbacks(modelHandle);
    if Simulink.internal.isArchitectureModel(modelHandle,'AUTOSARArchitecture')
        autosarcore.setArchModelCallbacks(modelHandle);
    end
end

function i_save(modelHandle,saveOptions)
    if Simulink.harness.isHarnessBD(modelHandle)
        return;
    end



    msgStream=autosar.mm.util.MessageStreamHandler.initMessageStreamHandler();

    cleanUpObj=onCleanup(@()msgStream.deactivate());

    if~autosarcore.ModelUtils.isMapped(modelHandle)

        saveOptions.writerHandle.deletePart(i_autosar_partinfo);
        return;
    end

    autosarcore.ModelUtils.uniquifyMappingName(modelHandle);

    mapping=autosarcore.ModelUtils.modelMapping(modelHandle);
    isExportToPreviousRelease=~isempty(saveOptions.targetRelease);
    isAutosarMapping=isa(mapping,'Simulink.AutosarTarget.ModelMapping');
    isSubComponent=isAutosarMapping&&mapping.IsSubComponent;
    if(~isAutosarMapping||~isSubComponent)&&(Simulink.slx.isPartDirty(modelHandle,'autosar')||isExportToPreviousRelease)





        autosarcore.M3IModelLoader.loadM3IModel(modelHandle,ReTargetExternalDanglingReferences=false);
        m3iModel=mapping.AUTOSAR_ROOT;


        fileName=Simulink.slx.getUnpackedFileNameForPart(modelHandle,i_partname);
        autosarcore.ModelUtils.writeM3IModelToFile(m3iModel,fileName,saveOptions.targetRelease);


        saveOptions.writerHandle.writePartFromFile(i_autosar_partinfo,fileName);



        if Simulink.AutosarDictionary.ModelRegistry.hasReferencedModels(m3iModel)
            Simulink.AutosarDictionary.ModelRegistry.setParentModelDirtyFlag(m3iModel,false);
        end
    end

end



