









function preloadFcn(runCfg,simInStruct,simWatcher,useParallel)

    try
        mainModel=simWatcher.mainModel;
        modelToRun=simInStruct.modelToRun;

        if useParallel

            stm.internal.checkoutCoverageLicense;
        end


        currFigs=handle(sort(double(findall(0,'type','figure'))));
        runCfg.runPreload(simInStruct);

        if(~simWatcher.modelResolved)
            if~bdIsLoaded(mainModel)
                load_system(mainModel);
            end
            simWatcher.resolveModelToRun();


            if(isa(runCfg.SimulationInput,'sltest.harness.SimulationInput'))
                Simulink.harness.internal.setBDLock(mainModel,false);
            end
        end

        if bdIsLibrary(modelToRun)||bdIsSubsystem(modelToRun)
            libID='Simulink:Engine:NoSimBlockDiagram';
            libError=getString(message(libID,modelToRun,get_param(modelToRun,'BlockDiagramType')));
            throw(MException(libID,libError));
        end

        h=get_param(modelToRun,'Handle');
        dataId='STM_FiguresData';

        if~Simulink.BlockDiagramAssociatedData.isRegistered(h,dataId)
            Simulink.BlockDiagramAssociatedData.register(h,dataId,'any');
            Simulink.BlockDiagramAssociatedData.set(h,dataId,currFigs);
        end

    catch me
        [tempErrors,tempErrorOrLog]=stm.internal.util.getMultipleErrors(me);
        runCfg.addMessages(tempErrors,tempErrorOrLog);
        try

            runCfg.runCleanup(simInStruct(1),[],true);
        catch ME
            stm.internal.SimulationInput.addExceptionMessages(runCfg,ME);
        end
        runCfg.out.overridesilpilmode=simInStruct.OverrideSILPILMode;
        rethrow(me);
    end
end
