function this=updateModelName(this,modelName,assumeSameSSIDs)






    if~isscalar(this)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoMethodNonScalar',...
        'updateModelName');
    end


    if nargin<2||~ischar(modelName)
        DAStudio.error(...
        'Simulink:Logging:MdlLogInfoInvalidUpdateModelArgs');
    end


    for idx=1:length(this.signals_)
        this.signals_(idx)=...
        this.signals_(idx).updateTopModelName(this.model_,modelName);
    end


    for idx=1:length(this.logAsSpecifiedByModels_)
        this.logAsSpecifiedByModels_{idx}=...
        Simulink.SimulationData.BlockPath.replaceModelName(...
        this.logAsSpecifiedByModels_{idx},...
        this.model_,...
        modelName);
    end


    prevModelName=this.model_;
    this.model_=modelName;

    if nargin<3||~assumeSameSSIDs


        this=this.cacheSSIDs(...
        false,...
        false);
    else
        prevModelPrefix=[prevModelName,':'];
        newModelPrefix=[modelName,':'];
        pl=length(prevModelPrefix);
        for idx=1:length(this.logAsSpecifiedByModelsSSIDs_)
            if strncmp(this.logAsSpecifiedByModelsSSIDs_{idx},prevModelPrefix,pl)
                this.logAsSpecifiedByModelsSSIDs_{idx}=...
                [newModelPrefix,this.logAsSpecifiedByModelsSSIDs_{idx}(pl+1:end)];
            end
        end
    end
end
