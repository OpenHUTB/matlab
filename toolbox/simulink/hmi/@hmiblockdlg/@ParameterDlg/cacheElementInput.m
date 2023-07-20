


function cacheElementInput(widgetId,model,srcBlockHandle,srcParamOrVar,srcWksType,elementInput)
    elementInput=elementInput(~isspace(elementInput));
    dlgs=DAStudio.ToolRoot.getOpenDialogs(true);
    for i=1:length(dlgs)
        dlgSrc=dlgs(i).getSource;
        if utils.isWidgetDialog(dlgSrc,widgetId,model)
            number=str2double(elementInput);
            if~isnan(number)&&number>0&&floor(number)==number
                dlgSrc.srcElement=['(',elementInput,')'];
            else
                dlgSrc.srcElement=elementInput;
            end
            if isempty(dlgSrc.srcBlockObj)
                dlgSrc.srcBlockObj=get_param(str2double(srcBlockHandle),'object');
                dlgSrc.srcParamOrVar=srcParamOrVar;
                dlgSrc.srcWksType=srcWksType;
            end
            paramDlgs=dlgSrc.getOpenDialogs(true);
            for j=1:length(paramDlgs)
                paramDlgs{j}.enableApplyButton(true,true);
            end
            break;
        end
    end
end