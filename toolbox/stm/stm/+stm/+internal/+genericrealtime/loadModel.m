function modelToRun=loadModel(model,subSystem,simWatcher)



    try

        if isempty(model)
            error(message('stm:general:NoModelSpecified'));
        end

        if exist(model,'file')~=4
            error(message('stm:general:ModelNotFoundOnPath',model));
        end



        modelUtil=stm.internal.util.SimulinkModel(model,subSystem);


        modelUtil.stopTimer();

        if(~isa(simWatcher.simModel,'stm.internal.util.SimulinkModel'))
            simWatcher.simModel=modelUtil;
        end

        if(~simWatcher.modelResolved)
            simWatcher.resolveModelToRun();
        end


        modelToRun=simWatcher.modelToRun;


        if(~strcmp(modelToRun,model))
            modelUtil.HarnessName=modelToRun;
        end


        simWatcher.originalTopModelDirty=get_param(model,'Dirty');

    catch ME
        rethrow(ME);
    end
end
