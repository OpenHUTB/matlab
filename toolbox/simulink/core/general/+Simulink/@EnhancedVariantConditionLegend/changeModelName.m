function changeModelName(this,oldModelName,newModelName)









    replaceElementIndex=this.findIndexForModel(oldModelName);



    if~isempty(replaceElementIndex)
        delete(this.legendDataForAllModels(replaceElementIndex).legendDlg);


        showLegend(this,newModelName);
    end

    if bdIsLoaded(newModelName)


        modelHandle=get_param(newModelName,'Handle');
        Simulink.addBlockDiagramCallback(modelHandle,...
        'PostNameChange','EnhancedVariantConditionLegend',...
        @()changeModelName(Simulink.EnhancedVariantConditionLegend.getInstance(),...
        newModelName,get_param(modelHandle,'Name')),...
        true);
    end
end
