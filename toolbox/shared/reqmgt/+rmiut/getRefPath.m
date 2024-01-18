function refPath=getRefPath(sourceObj)

    if isa(sourceObj,'Simulink.DDEAdapter')
        dName=sourceObj.getPropValue('DataSource');
        refPath=fileparts(rmide.resolveDict(dName));
    elseif ischar(sourceObj)
        [refPath,refName]=fileparts(strtok(sourceObj,'|'));
        if isempty(refPath)
            refPath=fileparts(which(refName));
        end
    elseif isa(sourceObj,'slreq.das.Requirement')
        reqSetPath=sourceObj.RequirementSet.Filepath;
        refPath=fileparts(reqSetPath);
        if isempty(refPath)
            refPath=pwd;
        end
    elseif isa(sourceObj,'slreq.data.Requirement')
        reqSetPath=sourceObj.getReqSet.filepath;
        refPath=fileparts(reqSetPath);
        if isempty(refPath)
            refPath=pwd;
        end
    else
        try
            modelPath=get_param(rmisl.getmodelh(sourceObj),'FileName');
        catch ex %#ok<NASGU>
            rmiut.warnNoBacktrace('Failed to get base path for argument of thpe %s',class(sourceObj));
            refPath=pwd;
            return;
        end
        if isempty(modelPath)
            error(message('Slvnv:reqmgt:selection_link_docpath:SaveModel'));
        else
            refPath=fileparts(modelPath);
        end
    end
end
