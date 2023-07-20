function[log,unapplied]=applyBDVarStructImpl(system,structName,varargin)















































    narginchk(2,Inf);


    pvArgDesc.ApplyMode={'apply','preview'};
    pvArgDesc.SearchMethod={'compiled','cached'};

    pvArgs=slprivate('slPVParser',pvArgDesc,varargin{:});

    log=[];
    unapplied=[];


    modelName=get_param(bdroot(system),'Name');
    sp=slResolve(structName,modelName,'expression','base');
    if~isstruct(sp)
        DAStudio.error('Simulink:tools:slVarStructNonStructArgument',structName);
    end

    spmap=[];
    spmap=getStructTermNodes(sp,structName,spmap);

    spdup=checkDuplicates(spmap);
    if~isempty(spdup)
        dupStr=getDuplicatesString(spdup);
        DAStudio.error('Simulink:tools:slVarStructDuplicatedNodes',...
        structName,dupStr);
    end



    hasAnyDD=slprivate('isUsingAnyDataDictionary',modelName);

    if slfeature('SLModelAllowedBaseWorkspaceAccess')>0
        varList=[];
        if strcmp(get_param(modelName,'HasAccessToBaseWorkspace'),'on')
            varList=Simulink.findVars(system,...
            'SourceType','base workspace',...
            'SearchMethod',pvArgs.SearchMethod,...
            'ReturnResolvedVar',true);
            pvArgs.SearchMethod='cached';
        end

        if hasAnyDD
            varListDD=Simulink.findVars(system,...
            'SourceType','data dictionary',...
            'SearchMethod',pvArgs.SearchMethod,...
            'ReturnResolvedVar',true);

            varList=cat(1,varList,varListDD);
        end
    else
        if~hasAnyDD
            sourceType='base workspace';
        else
            sourceType='data dictionary';
        end

        varList=Simulink.findVars(system,...
        'SourceType',sourceType,...
        'SearchMethod',pvArgs.SearchMethod);
    end


    if~isempty(varList)
        for n=1:size(spmap,1)
            varUsed=getVarUsed(varList,spmap{n,1});
            sizeofLog=size(log,1);
            numUnapplied=size(unapplied,1);

            [log,unapplied]=replaceModelParamVarName(varUsed,spmap{n,2},...
            pvArgs.ApplyMode,log,unapplied);

            if(isequal(sizeofLog,size(log,1))&&...
                isequal(numUnapplied,size(unapplied,1)))

                unapplied{end+1,1}=spmap{n,1};%#ok
                unapplied{end,2}=spmap{n,2};
                unapplied{end,3}='';
            end
        end
        if isempty(log)
            warning(message('Simulink:tools:ModelVarStructNoChangesApplied',modelName));
        end
    end
end


function spmap=getStructTermNodes(sp,path,spmap)
    assert(isstruct(sp));
    nodeNames=fieldnames(sp);
    for n=1:size(nodeNames,1)
        node=sp.(nodeNames{n});
        if isstruct(node)
            spmap=getStructTermNodes(node,[path,'.',nodeNames{n}],spmap);
        else
            spmap{end+1,1}=nodeNames{n};%#ok
            spmap{end,2}=[path,'.',nodeNames{n}];
        end
    end
end


function spdup=checkDuplicates(spmap)
    spdup=[];
    if isempty(spmap)
        return;
    end
    [sortedNames,sortedIdx]=sort(spmap(:,1));
    [~,uniqueIdx]=unique(sortedNames,'last');
















    seqIdx=1;
    for n=1:size(uniqueIdx,1)
        if(seqIdx<uniqueIdx(n))
            for seqIdx=seqIdx:uniqueIdx(n)
                dupIdx=sortedIdx(seqIdx);
                spdup{end+1,1}=spmap{dupIdx,1};%#ok
                spdup{end,2}=spmap{dupIdx,2};
            end
        end
        seqIdx=seqIdx+1;
    end
end


function dupStr=getDuplicatesString(spdup)
    eol=newline;
    tbl=sprintf('\t');
    dupStr=[];
    for n=1:size(spdup,1)
        dupStr=[dupStr,char(spdup(n,1)),tbl,char(spdup(n,2)),eol];%#ok
    end
end


function varUsed=getVarUsed(varList,varName)
    varUsed=findobj(varList,'Name',varName);
end


function[log,unapplied]=replaceModelParamVarName(varUsed,newVarName,...
    applyMode,log,unapplied)
    if isempty(varUsed)
        return;
    end


    oldVarName=varUsed.Name;
    allUsageDetails=varUsed.DirectUsageDetails;

    for n=1:numel(allUsageDetails)
        usageDetails=allUsageDetails(n);
        if~strcmp(usageDetails.UsageType,'Block')

            continue;
        end

        szlog=size(log,1);

        blkPath=usageDetails.Identifier;
        blkPrmNames=usageDetails.Properties;

        for nn=1:numel(blkPrmNames)
            if isempty(blkPrmNames{nn})
                continue;
            end

            log=replaceBlockParamVarName(blkPath,blkPrmNames{nn},...
            oldVarName,newVarName,...
            applyMode,log);
        end

        if isequal(szlog,size(log,1))

            unapplied{end+1,1}=oldVarName;%#ok
            unapplied{end,2}=newVarName;
            unapplied{end,3}=blkPath;
        end
    end
end


function log=replaceBlockParamVarName(blkPath,blkParamName,...
    oldVarName,newVarName,...
    applyMode,log)
    oldExpr='';
    isModelArg=false;


    if strcmp(get_param(blkPath,'BlockType'),'ModelReference')
        argInfo=get_param(blkPath,'InstanceParameters');
        argNames={argInfo.Name}';
        argIdx=find(strcmp(blkParamName,argNames));
        if numel(argIdx)==1
            isModelArg=true;
            oldExpr=argInfo(argIdx).Value;
        end
    end

    if~isModelArg
        try
            oldExpr=get_param(blkPath,blkParamName);
        catch e %#ok

        end
    end

    if~isempty(oldExpr)
        regExpr=['(?<![\w^.])',oldVarName,'(?!\w)'];
        newExpr=regexprep(oldExpr,regExpr,newVarName);

        if~isequal(oldExpr,newExpr)
            if isequal(applyMode,'apply')
                if isModelArg
                    argInfo(argIdx).Value=newExpr;
                    set_param(blkPath,'InstanceParameters',argInfo);
                else
                    set_param(blkPath,blkParamName,newExpr);
                end
            end

            log{end+1,1}=oldVarName;
            log{end,2}=newVarName;
            log{end,3}=blkPath;
            log{end,4}=blkParamName;
            log{end,5}=oldExpr;
            log{end,6}=newExpr;
        end
    end
end


