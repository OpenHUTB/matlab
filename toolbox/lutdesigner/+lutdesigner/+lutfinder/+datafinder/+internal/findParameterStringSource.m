function dataSource=findParameterStringSource(parameterOwner,parameterName,str)
    import lutdesigner.data.source.UnknownDataSource
    import lutdesigner.data.source.BaseWorkspaceVariable
    import lutdesigner.data.source.DataDictionaryEntry
    import lutdesigner.data.source.ModelWorkspaceVariable
    import lutdesigner.data.source.MaskWorkspaceVariable
    import lutdesigner.data.source.DialogParameter
    import lutdesigner.data.source.StructField

    curParameterOwner=getfullname(parameterOwner);
    curParameter=parameterName;
    strToResolve=strtrim(str);


    try
        [strContext,strType,strResolved,subFieldPathParts]=resolveParameterStringContext(curParameterOwner,curParameter,strToResolve);
    catch
        dataSource=UnknownDataSource(message('lutdesigner:data:cannotResolveExpr',strToResolve));
        return;
    end


    while isStrResolvedToMaskParameterName(curParameterOwner,strContext,strType,strResolved)

        if isStrResolvedToModelMaskParameterName(curParameterOwner,strContext,strType,strResolved)


            curParameterOwner=bdroot(curParameterOwner);
        else
            curParameterOwner=strContext;
        end
        curParameter=strResolved;
        strToResolve=strtrim(get_param(curParameterOwner,curParameter));


        [strContext,strType,strResolved,subFieldPathPartsResolved]=resolveParameterStringContext(curParameterOwner,curParameter,strToResolve);
        subFieldPathParts=[subFieldPathPartsResolved,subFieldPathParts];%#ok
    end


    switch strContext
    case 'Global'
        ddFilePath=findAssociatedDataDictionaryWithVariable(bdroot(curParameterOwner),strResolved);
        if~isempty(ddFilePath)
            dataSource=DataDictionaryEntry(ddFilePath,strResolved);
        else
            dataSource=BaseWorkspaceVariable(strResolved);
        end
    case 'Model'
        dataSource=ModelWorkspaceVariable(bdroot(curParameterOwner),strResolved);
    case 'Model Mask'
        dataSource=MaskWorkspaceVariable(bdroot(curParameterOwner),strResolved);
    otherwise
        if isStrContextValidBlockPath(strContext)
            strContext=adjustSourceContextIfIsOrIsInSubsystemReference(strContext);
            dataSource=MaskWorkspaceVariable(strContext,strResolved);
        else
            curParameterOwner=adjustSourceContextIfIsInSubsystemReference(curParameterOwner);
            dataSource=DialogParameter(curParameterOwner,curParameter);
        end
    end

    if~isempty(subFieldPathParts)
        dataSource=StructField(dataSource,subFieldPathParts);
    end
end

function[strContext,strType,strResolved,subFieldPathPartsResolved]=resolveParameterStringContext(parameterOwner,parameterName,strToResolve)
    import lutdesigner.utilities.resolveParameterString


    [~,strContext,strType]=lutdesigner.utilities.resolveParameterString(parameterOwner,parameterName,strToResolve);
    strResolved=strtrim(strToResolve);
    subFieldPathPartsResolved={};


    if strcmp(strType,'expression')
        fieldPathParts=parseExprAsPureStructFieldReference(parameterOwner,strToResolve);
        if~isempty(fieldPathParts)
            [~,strContext,strType]=resolveParameterString(parameterOwner,parameterName,fieldPathParts{1});
            strResolved=fieldPathParts{1};
            subFieldPathPartsResolved=fieldPathParts(2:end);
        end
    end
end

function tf=isStrResolvedToMaskParameterName(curParameterOwner,strContext,strType,strResolved)
    tf=isStrResolvedToBlockMaskParameterName(curParameterOwner,strContext,strType,strResolved)||...
    isStrResolvedToModelMaskParameterName(curParameterOwner,strContext,strType,strResolved);
end

function tf=isStrResolvedToBlockMaskParameterName(curParameterOwner,strContext,strType,strResolved)%#ok
    tf=isStrContextValidBlockPath(strContext)&&...
    ~isempty(Simulink.Mask.get(strContext).getParameter(strResolved));
end

function tf=isStrResolvedToModelMaskParameterName(curParameterOwner,strContext,strType,strResolved)%#ok
    tf=strcmp(strContext,'Model Mask')&&...
    ~isempty(Simulink.Mask.get(bdroot(curParameterOwner)).getParameter(strResolved));
end

function tf=isStrContextValidBlockPath(strContext)
    tf=getSimulinkBlockHandle(strContext)>0;
end

function tf=isBlockSubSystemReference(block)
    tf=strcmp(get_param(block,'BlockType'),'SubSystem')&&...
    ~isempty(get_param(block,'ReferencedSubsystem'));
end

function subsystemReference=findOwningSubSystemReference(parameterOwner)
    subsystemReference=[];
    parent=get_param(parameterOwner,'Parent');
    while~isempty(parent)&&strcmp(get_param(parent,'type'),'block')
        if isBlockSubSystemReference(parent)
            subsystemReference=parent;
            return;
        end
        parent=get_param(parent,'Parent');
    end
end

function sourceContext=adjustSourceContextIfIsInSubsystemReference(sourceContext)
    owningSubsystemReference=findOwningSubSystemReference(sourceContext);
    if~isempty(owningSubsystemReference)

        referencedSubsystem=get_param(owningSubsystemReference,'ReferencedSubsystem');
        sourceContext=[referencedSubsystem,extractAfter(sourceContext,owningSubsystemReference)];
    end
end

function sourceContext=adjustSourceContextIfIsOrIsInSubsystemReference(sourceContext)
    if isBlockSubSystemReference(sourceContext)
        sourceContext=get_param(sourceContext,'ReferencedSubsystem');
    else
        sourceContext=adjustSourceContextIfIsInSubsystemReference(sourceContext);
    end
end

function fieldPathParts=parseExprAsPureStructFieldReference(context,expr)





    fieldPathParts={};
    expr=strtrim(expr);


    exprParts=strsplit(expr,'.');
    if isscalar(exprParts)||any(cellfun(@(p)~isvarname(p),exprParts))
        return;
    end


    [value,exists]=slResolve(exprParts{1},context,'variable');
    if~(exists&&isstruct(value))
        return;
    end
    for i=2:numel(exprParts)-1
        value=value.(exprParts{i});
        if~isstruct(value)
            return;
        end
    end


    fieldPathParts=exprParts;
end

function ddFilePath=findAssociatedDataDictionaryWithVariable(model,variable)
    ddFilePath=[];

    ddName=get_param(model,'DataDictionary');
    if isempty(ddName)
        return;
    end

    dd=Simulink.data.dictionary.open(ddName);
    if~dd.HasUnsavedChanges
        oc=onCleanup(@()close(dd));
    end

    section=dd.getSection('Design Data');
    if~exist(section,variable)
        return;
    end

    ddFilePath=filepath(dd);
end
