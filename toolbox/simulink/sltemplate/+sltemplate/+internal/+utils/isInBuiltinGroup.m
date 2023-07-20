
function flag=isInBuiltinGroup(groupName)
    blocklist=["simulink","matlab"];
    if any(strcmpi(strtrim(groupName),blocklist))


        flag=true;
        return;
    end

    finder=dependencies.internal.analysis.toolbox.ToolboxFinder;
    flag=~isempty(finder.fromName(groupName));
end
