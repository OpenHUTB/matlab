function schema=menuEntry(~)




    schema=sl_action_schema;
    schema.label=lGetMessageString('DisplayMenuTitle');
    schema.callback=@lCallback;
    schema.tag='SimscapeMenu:VariableViewer';
    if simscape.internal.canShowGUI()
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function lCallback(cbInfo)

    model=getfullname(cbInfo.studio.App.blockDiagramHandle);
    simscape.state.openViewer(model,true);

end

function str=lGetMessageString(messageId)
    msgObj=message(['physmod:common:dataservices:gui:state:',messageId]);
    str=msgObj.getString();
end
