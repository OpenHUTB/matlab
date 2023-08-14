function showLegend(this,mdlName,varargin)





    indexOfModel=this.findIndexForModel(mdlName);
    if~isempty(indexOfModel)

        if this.isLegendOpen(indexOfModel)
            this.legendDataForAllModels(indexOfModel).legendDlg.refresh
            this.legendDataForAllModels(indexOfModel).legendDlg.show
            return;
        else


            addLegendDlg(this,indexOfModel,mdlName);
        end
    else



        this.legendDataForAllModels(end+1).uiCheckboxIndicator=false;
        this.legendDataForAllModels(end).modelName=mdlName;
        addLegendDlg(this,size(this.legendDataForAllModels,2),mdlName);
    end


    if bdIsLoaded(mdlName)


        modelHandle=get_param(mdlName,'Handle');
        Simulink.addBlockDiagramCallback(modelHandle,...
        'PreClose','EnhancedVariantConditionLegend',...
        @()removeModel(Simulink.EnhancedVariantConditionLegend.getInstance(),...
        get_param(modelHandle,'Name')),...
        true);



        Simulink.addBlockDiagramCallback(modelHandle,...
        'PostNameChange','EnhancedVariantConditionLegend',...
        @()changeModelName(Simulink.EnhancedVariantConditionLegend.getInstance(),...
        mdlName,get_param(modelHandle,'Name')),...
        true);
    end

    function addLegendDlg(eobj,indx,mdlName)



        temp=DAStudio.Dialog(eobj,mdlName,'DLG_STANDALONE');
        eobj.legendDataForAllModels(indx).legendDlg=temp;

