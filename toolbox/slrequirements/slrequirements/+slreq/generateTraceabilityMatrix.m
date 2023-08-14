























function generateTraceabilityMatrix(options)

    if builtin('_license_checkout','Simulink_Requirements','quiet')
        errordlg(getString(message('Slvnv:slreq:SimulinkRequirementsNoLicense')),...
        getString(message('Slvnv:slreq:SimulinkRequirements')),'modal');
        return
    end

    if nargin==0
        top={};
        left={};
        options.queryOtherDataInMemory=false;
        options.showArtifactSelector=false;
    else

        if isstruct(options)&&isfield(options,'options')
            options.leftArtifacts=options.options.LeftArtifacts;
            options.topArtifacts=options.options.TopArtifacts;
            options.options=options.options.getRawConfiguration;
        end

        options.queryOtherDataInMemory=false;
        if~isfield(options,'showArtifactSelector')
            options.showArtifactSelector=false;
        end
        if isfield(options,'leftArtifacts')
            left=options.leftArtifacts;
        else
            left={};
        end

        if isfield(options,'topArtifacts')
            top=options.topArtifacts;
        else
            top={};
        end

        if isfield(options,'options')
            options.options=options.options;
        else
            options.options={};
        end
    end

    [top,notExistTopFile,hasDuplicatedTopArtifact]=checkArtifacts(top);
    [left,notExistLeftFile,hasDuplicatedLeftArtifact]=checkArtifacts(left);


    filesNotExist=unique([notExistTopFile,notExistLeftFile]);

    if~isempty(filesNotExist)

        errorMsg=sprintf('\n\t');
        for index=1:length(filesNotExist)
            errorMsg=sprintf('\t%s%s\n\t',errorMsg,filesNotExist{index});
        end
        error(message('Slvnv:slreq_rtmx:APIErrorArtifactsFound',errorMsg));
    end

    if hasDuplicatedTopArtifact||hasDuplicatedLeftArtifact
        warning(message('Slvnv:slreq_rtmx:APIWarningArtifactsFound'));
    end
    slreq.report.rtmx.utils.generateRTMX(top,left,options);
end


function[outArtifacts,notExistFiles,hasDuplicatedArtifact]=checkArtifacts(inArtifacts)
    uniqueArtifactList=unique(inArtifacts,'stable');

    notExistFiles={};
    hasDuplicatedArtifact=false;
    outArtifacts={};
    if isempty(inArtifacts)
        return;
    end
    resolvedArtifacts={};
    if~isequal(uniqueArtifactList,inArtifacts)
        hasDuplicatedArtifact=true;
    end

    for index=1:length(uniqueArtifactList)
        if isempty(uniqueArtifactList{index})

            continue
        end
        fileObj=slreq.uri.FilePathHelper(uniqueArtifactList{index});
        if fileObj.doesExist&&slreq.report.rtmx.utils.MatrixArtifact.isSupportedArtifact(fileObj.getFullPath)
            resolvedArtifacts{end+1}=fileObj.getFullPath;%#ok<AGROW> not big
        else
            notExistFiles{end+1}=uniqueArtifactList{index};%#ok<AGROW> not big
        end
    end
    if isempty(resolvedArtifacts)

        return;
    end
    outArtifacts=unique(resolvedArtifacts,'stable');
    if~isequal(outArtifacts,resolvedArtifacts)
        hasDuplicatedArtifact=true;
    end
end