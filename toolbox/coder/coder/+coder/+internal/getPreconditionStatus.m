function[status]=getPreconditionStatus(aEntryPointNames)


















    if iscell(aEntryPointNames)
        entryPointNames=aEntryPointNames;
    else
        entryPointNames={aEntryPointNames};
    end
    project=coder.internal.Project;
    project.Client='CODEGEN';
    project.EntryPoints=coder.internal.EntryPoint('');
    for i=1:numel(entryPointNames)
        pathName=entryPointNames{i};
        [~,fcnName]=fileparts(pathName);
        if isempty(project.EntryPoints(end).Name)
            project.EntryPoints(end).Name=fcnName;
        else
            project.EntryPoints(end+1)=coder.internal.EntryPoint(fcnName);
        end
        project.EntryPoints(end).OriginName=fcnName;
        project.EntryPoints(end).UserInputName=pathName;
    end
    status=project.getPreconditions();
    if~iscell(aEntryPointNames)
        status=status{1};
    end
end

