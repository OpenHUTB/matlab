function schema=contextMenu(fcnName,cbInfo)

    fcn=str2func(['l',fcnName]);
    schema=fcn(cbInfo);

end

function schema=lSimscapeContextMenu(cbInfo)%#ok<DEFNU><DEFNU>
    schema=sl_container_schema;
    schema.label='&Simscape';
    schema.tag='Simscape:Simscape';
    schema.state='Hidden';
    schema.autoDisableWhen='Never';
    selection=cbInfo.getSelection;
    if(numel(selection)==1)&&...
        strcmpi(selection.Type,'block')
        if lHasChildren(selection.Handle)
            schema.state='Enabled';
        end
    end

    im=DAStudio.InterfaceManagerHelper(cbInfo.studio,'Simulink');
    children={...
    im.getAction('Simscape:SelectiveLogging'),...
    im.getAction('Simscape:BlockChoices'),...
    'separator',...
    im.getAction('Simscape:ViewSource'),...
    im.getAction('Simscape:RefreshSource'),...
    im.getAction('Simscape:ViewLogData')};

    schema.childrenFcns=children;

end

function schema=lSelectiveLogging(cbInfo)%#ok<DEFNU><DEFNU>
    schema=simscape.internal.contextMenuSelectiveLogging(cbInfo);
end

function schema=lBlockChoices(cbInfo)%#ok<DEFNU>
    schema=simscape.internal.contextMenuBlockChoices(cbInfo);
end

function schema=lViewSource(cbInfo)%#ok<DEFNU>
    schema=simscape.internal.contextMenuViewSource(cbInfo);
end

function schema=lRefreshSource(cbInfo)%#ok<DEFNU>
    schema=simscape.internal.contextMenuRefreshSource(cbInfo);
end

function schema=lViewLogData(cbInfo)%#ok<DEFNU>
    schema=simscape.internal.contextMenuViewLogData(cbInfo);
end

function result=lHasChildren(block)







    result=lIsSimscapeOrSM(block)&&lShowLogging(block);
end

function result=lIsSimscapeOrSM(block)
    blockObject=get_param(block,'Object');
    result=simscape.engine.sli.internal.issimscapeblock(block)||...
    isa(blockObject,'Simulink.SimscapeMultibodyBlock');
end

function result=lShowLogging(block)
    result=pmlog_is_logging_supported(block);
end
