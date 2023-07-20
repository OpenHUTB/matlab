function performCollection(this)








    try
        fptRepository=fxptds.FPTRepository.getInstance;

        topModelObj=get_param(this.sysToScaleName,'Object');





        topModelOrSubsystemName=SimulinkFixedPoint.AutoscalerUtils.getModelForAutoscaling(topModelObj);


        topDataset=fptRepository.getDatasetForSource(topModelOrSubsystemName);
        topRunObj=topDataset.getRun(this.proposalSettings.scaleUsingRunName);

        if topRunObj.actionExists(SimulinkFixedPoint.DataTypingServices.EngineActions.Collect)






            fxptds.Utils.setLastUpdatedRun(this.refMdls,this.proposalSettings.scaleUsingRunName);

            return;
        end

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


        topDataset.setLastUpdatedRun(this.proposalSettings.scaleUsingRunName);

        topRunObj.initialize(topModelOrSubsystemName);



        this.scale_collect(topModelObj,topModelOrSubsystemName,topRunObj);

        topRunObj.pushAction(SimulinkFixedPoint.DataTypingServices.EngineActions.Collect);

    catch scaleError
        rethrow(scaleError);
    end
end
