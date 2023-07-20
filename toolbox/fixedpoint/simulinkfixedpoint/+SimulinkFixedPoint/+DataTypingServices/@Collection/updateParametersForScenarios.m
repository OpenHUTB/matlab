function updateParametersForScenarios(this)









    for sIndex=2:length(this.simIn)

        modelState=Simulink.internal.TemporaryModelState(this.simIn(sIndex));
        modelState.RevertOnDelete=false;


        for mIndex=1:numel(this.refMdls)
            this.updateParametersForModel(this.refMdls{mIndex});
        end




        revert(modelState);
    end
end

