function changeModelName(this,oldModelName,newModelName)




    modelIndex=find(strcmp(oldModelName,this.modelList));
    modelIndex=modelIndex(1);
    if(~isempty(modelIndex))
        this.modelList{modelIndex}=newModelName;
        this.currentTabIndex=modelIndex-1;
        this.modelName=newModelName;

        if(length(this.modelLegendState)>=modelIndex&&...
            strcmp(this.modelLegendState{modelIndex},'on'))
            this.showLegend(newModelName);
        end
    end

    if bdIsLoaded(newModelName)


        modelHandle=get_param(newModelName,'Handle');
        Simulink.addBlockDiagramCallback(modelHandle,...
        'PostNameChange','SampleTimeLegend',...
        @()changeModelName(Simulink.SampleTimeLegend,...
        newModelName,get_param(modelHandle,'Name')),...
        true);
    end
end



