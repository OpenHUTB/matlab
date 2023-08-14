function applyTolerances(this,dlg)



    if Simulink.sdi.enableTolerancesDataEntry
        locApplyTolerance(this,dlg,'txtRelativeTolerance','RelTol');
        locApplyTolerance(this,dlg,'txtAbsoluteTolerance','AbsTol');
    end
end


function locApplyTolerance(this,dlg,widgetTag,toleranceMode)
    instrumentSignalIfNeeded(this);


    tolStr=dlg.getWidgetValue(widgetTag);


    [blockPath,portIndex]=this.elaborateContext();

    if isempty(tolStr)


        Simulink.sdi.internal.Utils.setToleranceInModel(blockPath,portIndex,toleranceMode,[]);
    else

        tolValue=str2double(tolStr);
        if isnan(tolValue)


            previousTolValue=Simulink.sdi.internal.Utils.getToleranceFromModel(blockPath,portIndex,toleranceMode);
            dlg.setWidgetValue(widgetTag,num2str(previousTolValue));
        else
            Simulink.sdi.internal.Utils.setToleranceInModel(blockPath,portIndex,toleranceMode,tolValue);
        end
    end
end
