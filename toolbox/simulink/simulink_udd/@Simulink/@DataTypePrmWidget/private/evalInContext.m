









function value=evalInContext(hDialog,dlgPrm)



    if strcmp(hDialog.getTitle,DAStudio.message('Simulink:dialog:UDTDataTypeAssistGrp'))
        hDialogSource=hDialog.getSource.p_hDlgSource;
    else
        hDialogSource=hDialog.getSource;
    end
    if isa(hDialogSource,'Simulink.SLDialogSource')

        hBlock=hDialogSource.getBlock;
        context=getFullName(hBlock);
        value=slResolve(dlgPrm,context);
    elseif isa(hDialogSource,'Stateflow.Object')

        chartId=sf('DataChartParent',hDialogSource.Id);
        if~isempty(chartId)&&chartId>0
            blockH=sf('Private','chart2block',chartId);
            context=getfullname(blockH);
            value=slResolve(dlgPrm,context);
        else
            value=evalin('base',dlgPrm);
        end
    else
        value=evalin('base',dlgPrm);
    end



