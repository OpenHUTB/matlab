


function gaugeSettingsChanged(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');
    blockType=get_param(blockHandle,'BlockType');
    mdl=get_param(bdroot(blockHandle),'Name');
    if Simulink.HMI.isLibrary(mdl)
        return;
    end


    minVal=strtrim(dlg.getWidgetValue('minimumValue'));
    maxVal=strtrim(dlg.getWidgetValue('maximumValue'));
    tickVal=strtrim(dlg.getWidgetValue('tickInterval'));
    success=...
    utils.validateMinMaxTickIntervalFields(minVal,maxVal,tickVal,dlg,true);
    if~success
        return
    end


    set_param(blockHandle,...
    'ScaleMin',minVal,...
    'ScaleMax',maxVal,...
    'TickInterval',tickVal);

    MinMaxTickIntervalPropertiesToUpdate{1}=[];
    MinMaxTickIntervalPropertiesToUpdate{2}=minVal;
    MinMaxTickIntervalPropertiesToUpdate{3}=maxVal;
    MinMaxTickIntervalPropertiesToUpdate{4}=tickVal;

    dlg.clearWidgetWithError('minimumValue');
    dlg.clearWidgetWithError('maximumValue');
    dlg.clearWidgetWithError('tickInterval');

    dlg.clearWidgetDirtyFlag('minimumValue');
    dlg.clearWidgetDirtyFlag('maximumValue');
    dlg.clearWidgetDirtyFlag('tickInterval');


    signalDlgs=obj.getOpenDialogs(true);
    for j=1:length(signalDlgs)
        if~isequal(dlg,signalDlgs{j})
            utils.updateMinMaxTickIntervalFields(signalDlgs{j},MinMaxTickIntervalPropertiesToUpdate);
        end
    end
end
