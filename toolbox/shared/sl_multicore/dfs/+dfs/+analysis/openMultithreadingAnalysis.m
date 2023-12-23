function openMultithreadingAnalysis(subsystem)

    if isempty(subsystem)
        return;
    end

    system=getTopDataflowSubsystem(subsystem);
    if isempty(system)
        dialogProvider=DAStudio.DialogProvider;
        errordlg(dialogProvider,...
        getString(message('dataflow:MultithreadingAnalysis:DataflowNotDetected')),...
        getString(message('dataflow:MultithreadingAnalysis:DialogTitle',getfullname(subsystem))),...
        true);
        return;
    end

    cache=dfs.analysis.InstanceCache.getInstance();
    open(cache,get_param(system,'Handle'));
end

function topSystem=getTopDataflowSubsystem(block)
    topSystem='';
    parent=block;
    while~isempty(parent)
        if strcmp(get_param(parent,'Type'),'block')...
            &&strcmp(get_param(parent,'BlockType'),'SubSystem')...
            &&strcmpi(get_param(parent,'SetExecutionDomain'),'on')...
            &&strcmpi(get_param(parent,'ExecutionDomainType'),'dataflow')
            topSystem=parent;
        end
        parent=get_param(parent,'Parent');
    end
end


