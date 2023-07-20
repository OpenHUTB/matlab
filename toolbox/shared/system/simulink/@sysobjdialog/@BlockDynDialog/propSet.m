function propSet(this,dlg,paramName,paramValue)



    this.DialogManager.propSet(dlg,paramName,paramValue);



    maskObject=getMaskObject(this.DialogManager.Platform);
    paramNames={maskObject.Parameters.Name};
    if isempty(paramNames)
        return;
    end
    index=find(strcmp(paramName,paramNames));



    index=index-1;
    allWidgets=DAStudio.imDialog.getIMWidgets(dlg);
    thisWidget=allWidgets.find('Tag',paramName);
    if isempty(thisWidget)

        thisWidget=gleeTestInternal.GLWidget2.find(paramName);
        if~isempty(thisWidget)
            this.handleDialEvent(paramValue,index,dlg);
        end
    else
        switch thisWidget.Type
        case 'ITM_Edit'
            this.handleEditEvent(paramValue,index,dlg);
        case 'ITM_EditArea'
            this.handleEditEvent(paramValue,index,dlg);
        case 'ITM_CheckBox'
            this.handleCheckEvent(paramValue,index,dlg);
        case 'ITM_ComboBox'
            this.handleComboSelectionEvent(paramValue,index,dlg);
        case 'ITM_RadioButton'
            this.handleRadioButtonSelectionEvent(paramValue,index,dlg);
        otherwise
            warning(message('MATLAB:system:unknownWidgetType'));
        end
    end
    updateWidgetLabelVisibilities(this.DialogManager.Platform,dlg);
    dlg.refresh();
