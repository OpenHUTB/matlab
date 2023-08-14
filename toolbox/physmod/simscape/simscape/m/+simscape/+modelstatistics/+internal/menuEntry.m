function schema=menuEntry(~)




    schema=sl_action_schema;
    schema.label=lGetMessageString('DisplayMenuTitle');
    schema.callback=@lCallback;
    schema.tag='SimscapeMenu:Statistics';
    if simscape.internal.canShowGUI()
        schema.state='Enabled';
    else
        schema.state='Disabled';
    end
    schema.autoDisableWhen='Busy';
end

function lCallback(cbInfo)

    model=getfullname(cbInfo.studio.App.blockDiagramHandle);
    simscape.modelstatistics.open(model,true);

end

function str=lGetMessageString(messageId)
    msgObj=message(['physmod:common:statistics:gui:kernel:',messageId]);
    str=msgObj.getString();
end
