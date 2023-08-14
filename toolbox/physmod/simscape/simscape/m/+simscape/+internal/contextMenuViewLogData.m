function schema=contextMenuViewLogData(cbInfo)



    schema=sl_container_schema;
    schema.label=getString(message('physmod:simscape:simscape:menus:ViewSimulationData'));
    schema.tag='Simscape:Logging';
    schema.state='Hidden';
    schema.autoDisableWhen='Never';
    schema.generateFcn=@createLoggingEntries;
    if(numel(cbInfo.getSelection)==1)&&strcmpi(cbInfo.getSelection.Type,'block')
        if lIsLoggingSupported(cbInfo.getSelection.Handle)
            blockName=cbInfo.getSelection.getFullName;
            names=simscape.logging.sli.internal.loggingVariablesInBaseForBlock(blockName);
            if~isempty(names)
                schema.state='Enabled';
            else
                schema.state='Disabled';
            end
        end
    end
end

function schema=createLoggingEntries(cb)
    blockName=cb.getSelection.getFullName;
    names=simscape.logging.sli.internal.loggingVariablesInBaseForBlock(blockName);
    schema=cell(size(names));
    for idx=1:numel(names)
        schema{idx}={@loggingEntry,names{idx}};
    end

end

function s=loggingEntry(cb)



    s=sl_action_schema;
    s.autoDisableWhen='Never';
    s.label=cb.userdata;


    s.callback=@lExploreData;
    s.userdata=cb.userdata;
    s.tag=['Simscape:LogData:',s.userdata];
end

function lExploreData(cb)
    blockHandle=cb.getSelection.Handle;
    varName=cb.userdata;
    vars=textscan(varName,'%s','delimiter','.');
    vars=vars{:};
    pm_assert(numel(vars)<3,...
    'Simscape logging does not support more than one level of hierarchy');
    if(numel(vars)==1)
        simlog=evalin('base',vars{1});
        varName=vars{1};
    else
        out=evalin('base',vars{1});
        pm_assert(isa(out,'Simulink.SimulationOutput'),...
        sprintf('''%s'' is not single output',vars{1}));
        simlog=out.get(vars{2});
        varName='';
    end

    simscape.logging.sli.internal.explore(simlog,...
    blockHandle,varName);
end

function result=lIsLoggingSupported(block)

    result=pmlog_is_logging_supported(block);
end

