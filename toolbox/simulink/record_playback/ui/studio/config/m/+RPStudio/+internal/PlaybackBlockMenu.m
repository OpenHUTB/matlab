


function schema=PlaybackBlockMenu(fncname,cbinfo,eventData)
    fnc=str2func(fncname);
    if nargout(fnc)
        schema=fnc(cbinfo);
    else
        schema=[];
        if nargin==3
            fnc(cbinfo,eventData);
        else
            fnc(cbinfo);
        end
    end
end




function pbSignalAddCallback(cbinfo)
    config=[];
    config.BlockId=get_param(cbinfo.uiObject.Handle,'BlockId');
    app=Simulink.playback.mainApp.getController(config);
    app.AddDataUi.openGUI();
    app.AddDataUi.bringToFront();
end

function pbAddCallback(cbinfo)
    pbSignalAddCallback(cbinfo);
end

function pbAddPortCallback(cbinfo)
    existingNumPorts=get_param(cbinfo.uiObject.Handle,'NumPorts');
    set_param(cbinfo.uiObject.Handle,'NumPorts',existingNumPorts+1);
end

function pbDeleteCallback(cbinfo)

    Simulink.playback.internal.publishMessage(cbinfo.uiObject.Handle,'confirmdelete');
end

function pbDeleteAllCallback(cbinfo)

    Simulink.playback.internal.publishMessage(cbinfo.uiObject.Handle,'confirmdeleteall');
end

function pbZeroCrossingDetectionCallback(cbinfo)
    if cbinfo.EventData
        set_param(cbinfo.uiObject.Handle,'ZeroCross','on');
    else
        set_param(cbinfo.uiObject.Handle,'ZeroCross','off');
    end
end

function pbBeforeFirstLinearExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationBeforeFirstDataPoint',...
    "Linear extrapolation");
end

function pbBeforeFirstHFVExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationBeforeFirstDataPoint',...
    "Hold first value");
end

function pbBeforeFirstGroundExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationBeforeFirstDataPoint',...
    "Ground value");
end

function pbAfterLastLinearExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationAfterLastDataPoint',...
    "Linear extrapolation");
end

function pbAfterLastHFVExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationAfterLastDataPoint',...
    "Hold last value");
end

function pbAfterLastGroundExtrapolation(cbinfo)
    set_param(cbinfo.uiObject.Handle,'ExtrapolationAfterLastDataPoint',...
    "Ground value");
end

function pbHelpCB(~)
    helpview('simulink','playbackblock');
end

function pbExamplesCB(~)
    helpview('simulink','playbackblock_example');
end

function pbPortsEditorCallback(cbinfo)
    blockHandle=cbinfo.uiObject.Handle;
    editor=cbinfo.studio.App.getActiveEditor();
    portEditor=RPStudio.internal.PortsEditor(blockHandle,editor);
    if cbinfo.EventData
        portEditor.show;
        set_param(blockHandle,'PortEditorStatus','On');
    else
        portEditor.hide;
        set_param(blockHandle,'PortEditorStatus','Off');
    end
end

function pbRefreshCallback(cbinfo)

    blockHandle=cbinfo.uiObject.Handle;
    Simulink.playback.internal.refreshSignalsInBlock(blockHandle);
end

function pbSparklinesSortCallback(cbinfo)
    view=get_param(cbinfo.uiObject.Handle,'View');
    view.sortSparklines=cbinfo.EventData;
end
