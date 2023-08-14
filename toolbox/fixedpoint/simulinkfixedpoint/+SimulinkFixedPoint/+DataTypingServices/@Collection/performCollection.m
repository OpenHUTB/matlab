function performCollection(this)


    try
        fptRepository=fxptds.FPTRepository.getInstance;
        for idx=1:(length(this.refMdls)-1)
            modelName=this.refMdls{idx};
            load_system(modelName);


            modelObj=get_param(modelName,'Object');





            modelOrSubsystemName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(modelObj);

            dataset=fptRepository.getDatasetForSource(modelOrSubsystemName);


            dataset.setLastUpdatedRun(this.proposalSettings.scaleUsingRunName);

            runObj=dataset.getRun(this.proposalSettings.scaleUsingRunName);
            runObj.initialize(modelOrSubsystemName);



            this.scale_collect(modelObj,modelOrSubsystemName,runObj);
        end


        modelObj=get_param(this.sysToScaleName,'Object');





        modelOrSubsystemName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(modelObj);


        dataset=fptRepository.getDatasetForSource(modelOrSubsystemName);
        runObj=dataset.getRun(this.proposalSettings.scaleUsingRunName);


        dataset.setLastUpdatedRun(this.proposalSettings.scaleUsingRunName);

        runObj.initialize(modelOrSubsystemName);



        this.scale_collect(modelObj,modelOrSubsystemName,runObj);

    catch scaleError
        rethrow(scaleError);
    end
end
