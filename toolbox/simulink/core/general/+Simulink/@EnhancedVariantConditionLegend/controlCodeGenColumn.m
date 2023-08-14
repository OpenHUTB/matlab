function controlCodeGenColumn(this,action,mdlName)



    indexOfModel=this.findIndexForModel(mdlName);
    if~isempty(indexOfModel)
        this.legendDataForAllModels(indexOfModel).uiCheckboxIndicator=action;
        spreadSheetTag=this.spreadSheetTag;
        spreadSheetComp=this.legendDataForAllModels(indexOfModel).legendDlg.getWidgetInterface(spreadSheetTag);

        if action
            columnNames={DAStudio.message('Simulink:utility:AnnotationWithoutColon'),...
            DAStudio.message('Simulink:utility:VariantConditions'),...
            DAStudio.message('Simulink:utility:VariantConditionSRC'),...
            DAStudio.message('Simulink:utility:VariantConditionCG')};
        else
            columnNames={DAStudio.message('Simulink:utility:AnnotationWithoutColon'),...
            DAStudio.message('Simulink:utility:VariantConditions'),...
            DAStudio.message('Simulink:utility:VariantConditionSRC')};
        end
        spreadSheetComp.setColumns(columnNames,'','',false);
        spreadSheetComp.update;
    else
        assert(false,"we should never be here");
    end

end

