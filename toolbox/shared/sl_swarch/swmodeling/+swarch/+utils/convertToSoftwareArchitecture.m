function convertToSoftwareArchitecture(fromModel,toModel)











    if nargin<2
        toModel=[fromModel,'_',regexprep(datestr(now),'[-|:| ]','_')];
    end




    if bdIsLoaded(fromModel)
        new_system(toModel,'FromFile',get_param(fromModel,'FileName'));
    else
        new_system(toModel,'FromFile',which(fromModel));
    end
    model=get_param(toModel,'SystemComposerModel');



    try
        if isempty(model)
            error(message('SystemArchitecture:Architecture:InvalidOrDeletedSystemComposerModel'));
        end


        convertToSoftware(model.Architecture.getImpl());
        SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(...
        model.SimulinkHandle,SimulinkSubDomainMI.SimulinkSubDomainEnum.SoftwareArchitecture);
        set_param(model.SimulinkHandle,'Solver','FixedStepDiscrete');

        for comp=model.Architecture.getImpl.getComponentsAcrossHierarchy()
            blkH=systemcomposer.utils.getSimulinkPeer(comp);
            if comp.isAdapterComponent()

                comp.p_Adaptation.clearAdaptations();
            elseif~comp.isImplComponent()

                convertToSoftware(comp.getArchitecture());
                SimulinkSubDomainMI.SimulinkSubDomain.setSimulinkSubDomain(...
                blkH,SimulinkSubDomainMI.SimulinkSubDomainEnum.SoftwareArchitecture);
            else
                set_param(blkH,'ScheduleRates','on');
                set_param(blkH,'ScheduleRatesWith','Ports');
            end
        end
        open_system(toModel);
    catch ex
        close_system(toModel,0);
        rethrow(ex);
    end
end

function convertToSoftware(archImpl)


    archImpl.addTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass);
    archImpl.setIsSoftwareArchitecture();
end
