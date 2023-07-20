function taskNames=getTaskNames(taskMgr)




    import soc.internal.connectivity.*

    taskMgrOutports=getSystemOutputPorts(taskMgr);
    y=arrayfun(@(x)(strfind(x,'/')),taskMgrOutports);
    x=cellfun(@(x)(x(end)),y);
    for idx=1:numel(taskMgrOutports)
        taskNames{idx}=taskMgrOutports{idx}(x(idx)+1:end);%#ok<AGROW>
    end
end