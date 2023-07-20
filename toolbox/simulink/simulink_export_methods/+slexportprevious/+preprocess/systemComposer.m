function systemComposer(obj)




    if isR2022aOrEarlier(obj.ver)

        if(slfeature('SoftwareModelingAutosar')>0)&&...
            strcmp(get_param(obj.modelName,'SimulinkSubDomain'),'AUTOSARArchitecture')
            set_param(obj.modelName,'AutosarExportToRateBasedArch','on');
            ret=onCleanup(@()set_param(obj.modelName,'AutosarExportToRateBasedArch','off'));


            inpBlks=slexportprevious.utils.findBlockType(obj.modelName,'Inport',...
            'OutputFunctionCall','on');
            for i=1:length(inpBlks)
                delete_block(inpBlks{i});
            end


            mdlBlks=slexportprevious.utils.findBlockType(obj.modelName,'ModelReference');
            for i=1:length(mdlBlks)
                set_param(mdlBlks{i},'ScheduleRatesWith','Schedule Editor');
            end


            archMdl=get_param(obj.modelName,'SystemComposerModel');
            fcns=archMdl.Architecture.Functions;
            for i=1:length(fcns)
                fcns(i).destroy();
            end


            trait=archMdl.Architecture.getImpl().getTrait(...
            systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            archMdl.Architecture.getImpl().removeTrait(...
            systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
            trait.destroy();
            archMdl.Architecture.getImpl().setIsArchitecture();
            comps=archMdl.Architecture.getImpl.getComponentsAcrossHierarchy();
            for comp=comps
                trait=comp.getArchitecture().getTrait(...
                systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
                comp.getArchitecture().removeTrait(...
                systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
                trait.destroy();
                if comp.getArchitecture().isSoftwareArchitecture()
                    comp.getArchitecture().setIsArchitecture();
                end
            end
        end

    end



