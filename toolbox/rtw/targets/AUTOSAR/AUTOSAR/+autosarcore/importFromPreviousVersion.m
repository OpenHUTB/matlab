function importFromPreviousVersion(mdlH)






    if~autosarinstalled()
        return;
    end

    mapping=autosarcore.ModelUtils.modelMapping(mdlH);
    if get_param(mdlH,'VersionLoaded')<10.1



        if isa(mapping,'Simulink.AutosarTarget.ModelMapping')
            autosar.mm.sl2mm.ComSpecBuilder.checkAndGenerateComSpecsForMappedDataElements(mapping);
        end
    end
    if get_param(mdlH,'VersionLoaded')<10

        loc_remapOutportEvents(mapping);
    end
    if(get_param(mdlH,'VersionLoaded')==10)||...
        (get_param(mdlH,'VersionLoaded')==10.1)

        if isa(mapping,'Simulink.AutosarTarget.AdaptiveModelMapping')


            m3iModel=autosarcore.M3IModelLoader.loadM3IModel(mdlH);
            modelName=get_param(mdlH,'Name');
            [mdgPkgName,defModeDeclGrpName]=autosar.internal.adaptive.manifest.ManifestUtilities.getModeDeclPkgAndGroupNames(modelName);
            m3iSeq=autosarcore.MetaModelFinder.findObjectByName(m3iModel,['/',mdgPkgName,'/',defModeDeclGrpName]);
            if(m3iSeq.size()==1)
                t=M3I.Transaction(m3iModel);
                autosar.internal.adaptive.manifest.ManifestUtilities.markElementAsManifestARXML(m3iSeq.at(1));
                t.commit();
            end
        end
    end
end

function loc_remapOutportEvents(mapping)
    if isa(mapping,'Simulink.AutosarTarget.AdaptiveModelMapping')


        outports=mapping.Outports;
        for ii=1:length(outports)
            curPort=outports(ii);
            portName=curPort.MappedTo.Port;
            eventName=curPort.MappedTo.Event;
            curPort.mapPortProvidedEvent(portName,eventName,'false','');
        end
    end
end
