function[modifiedObjects,message]=mergeSimulink(type,mergeActionData)






















    message='';
    action=char(mergeActionData.getActionName());

    switch action
    case 'Delete'
        modifiedObjects=i_DeleteObject(type,mergeActionData);
    case 'Insert'
        [modifiedObjects,message]=i_InsertObject(type,mergeActionData);
    case 'Parameter'
        modifiedObjects=i_MergeParameter(type,mergeActionData);
    otherwise
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end
end







function modifiedObjects=i_DeleteObject(type,mergeActionData)


    modifiedObjects=java.util.ArrayList;


    dstNode=mergeActionData.getToNode();
    dstPath=char(dstNode.getNodePath());

    switch type
    case 'Annotation'

        object=slxmlcomp.internal.annotation.find(...
        slxmlcomp.internal.annotation.highlightPathToStruct(dstPath)...
        );
        delete(object);

    case{'Block','chart'}
        object=i_GetObject(dstPath);



        if isSubChart(dstNode)
            lines=[];
        else
            lines=i_GetAffectedLines(mergeActionData.getAffectedNodes());
        end


        oldVal=warning('off','Simulink:Harness:HarnessDeletedForBlock');
        restoreWarning=onCleanup(@()warning(oldVal));


        delete_block(object);



        i_UpdateLines(lines,mergeActionData);



        arrayfun(@(x)modifiedObjects.add(x.jLine),lines);

    case 'Line'

        line=i_GetLine(dstPath);
        delete_line(line.Handle);

    otherwise
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end

end

function subChart=isSubChart(node)
    subChart=false;
    if~strcmp(char(node.getTagName()),'chart')
        return
    end
    parent=node.getParent();
    if isempty(parent)
        return
    end
    subChart=strcmp(char(parent.getTagName()),'chart');
end


function[modifiedObjects,message]=i_InsertObject(type,mergeActionData)


    modifiedObjects=java.util.ArrayList;
    message='';


    srcNode=mergeActionData.getFromNode();
    dstNode=mergeActionData.getToNode();
    srcPath=char(srcNode.getNodePath());
    dstPath=char(dstNode.getNodePath());

    affectedLines=mergeActionData.getAffectedNodes();
    sourceSource=mergeActionData.getFromSource();
    targetSource=mergeActionData.getToSource();
    parameterUpdater=mergeActionData.getParameterUpdater();
    differences=mergeActionData.getDiffSet();

    switch type
    case 'Annotation'
        srcHandle=slxmlcomp.internal.annotation.find(...
        slxmlcomp.internal.annotation.highlightPathToStruct(srcPath)...
        );

        srcHL=i_ClearHighlighting(srcHandle);



        newBlockPath=[dstPath,'/mergedAnnotation'];
        dstHandle=add_block('built-in/Note',newBlockPath);

        srcParams=i_GetObjectParameters(srcHandle);
        dstParams=i_GetObjectParameters(dstHandle);

        parameterDifferences=i_GetParameterDifferences(srcParams,dstParams,{});
        slxmlcomp.internal.merge.copyValues(dstHandle,parameterDifferences);

        newNode=i_CreateNode(srcNode);
        modifiedObjects.add(newNode);

        updateSIDForNode(dstHandle,newNode);

        i_RestoreHighlighting(srcHandle,srcHL);
    case{'chart','Block','System'}


        if isSubChart(srcNode)
            lines=[];
        else
            lines=i_GetAffectedLines(affectedLines);
        end

        newObj=addBlockAndUpdateLibraryLinks(srcPath,dstPath);

        newNode=i_CreateNode(srcNode);
        newNode.setParameterValue('Name',get_param(newObj,'Name'));
        modifiedObjects.add(newNode);

        updateSIDForNode(newObj,newNode);


        i_UpdateLines(lines,mergeActionData);
        arrayfun(@(x)modifiedObjects.add(x.jLine),lines);

    case 'Line'

        srcLine=i_GetLine(srcPath);
        lines=i_GetAffectedLines(affectedLines);


        lineChildren=srcLine.Children;

        if isempty(lineChildren)

            [dstLine,message]=i_ConnectLine(srcNode,dstNode,srcLine,lines,differences,targetSource,sourceSource);
        else


            visitedLines=[];
            [dstLine,message]=i_ConnectChildren(srcNode,dstNode,lineChildren,'',differences,targetSource,sourceSource,visitedLines);
        end



        if isempty(dstLine)
            return
        end



        lineParent=dstLine.Parent;
        if~isempty(lineParent)
            dstLine=lineParent;
        end


        paramDifferences=i_GetParameterDifferences(i_GetObjectParameters(srcLine.Handle),i_GetObjectParameters(dstLine.Handle),{});
        paramDifferences=slxmlcomp.internal.merge.copyValues(dstLine,paramDifferences);
        newNode=i_CreateNode(srcNode);

        import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.line.LineUtils;
        paramDifferences=[paramDifferences;...
        {LineUtils.SRC_BLOCK_PARAMETER_NAME,dstLine.SrcBlockName,''};
        {LineUtils.DST_BLOCK_PARAMETER_NAME,dstLine.DstBlockName,''};
        {LineUtils.SRC_PORT_PARAMETER_NAME,dstLine.SrcPortNumberStr,''};
        {LineUtils.DST_PORT_PARAMETER_NAME,dstLine.DstPortNumberStr,''};
        {LineUtils.SRC_BLOCK_ID_PARAMETER_NAME,dstLine.SrcBlockSID,''};
        {LineUtils.DST_BLOCK_ID_PARAMETER_NAME,dstLine.DstBlockSID,''};
        {LineUtils.POINTS_PARAMETER_NAME,dstLine.Points,''}];

        targetChoice=mergeActionData.getFromSide();
        parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
        slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,newNode,paramDifferences,true,false,srcNode,targetChoice,parameterNameToDiffMap);



        i_AddLineHandleParameter(newNode,dstLine);

        modifiedObjects.add(newNode);

    otherwise
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end
end

function updateSIDForNode(objectHandle,jNode)
    sidParameterName='SID';
    newSID=get_param(objectHandle,sidParameterName);
    import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
    sidParameter=LightweightNodeUtils.getParameter(jNode,sidParameterName);
    if isempty(sidParameter)
        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightArtificialParameter;
        jNode.addParameter(LightweightArtificialParameter(sidParameterName,newSID,false));
    else
        sidParameter.setValue(newSID);
    end
end

function newObj=addBlockAndUpdateLibraryLinks(srcPath,dstPath)
    newBlock=[dstPath,'/',strrep(get_param(srcPath,'Name'),'/','//')];
    newObj=mergeInsertBlock(srcPath,newBlock);
    updateLibraryLinks(newObj,newBlock,srcPath);
end

function newObj=mergeInsertBlock(srcPath,newBlock)
    params=get_param(srcPath,'ObjectParameters');
    if isfield(params,'TemplateBlock')&&~isempty(get_param(srcPath,'TemplateBlock'))


        newObj=add_block('simulink/Ports & Subsystems/Configurable Subsystem',newBlock,'MakeNameUnique','on');
        names=fieldnames(params);
        values=cellfun(@(p)get_param(srcPath,p),names,'UniformOutput',false);

        for ii=1:length(names)
            try %#ok<TRYNC>
                set_param(newObj,names{ii},values{ii});
            end
        end
    elseif strcmp(get_param(srcPath,'StaticLinkStatus'),'none')


        newObj=add_block(srcPath,newBlock,'CopyOption','noLink','MakeNameUnique','on');
    else

        newObj=add_block(srcPath,newBlock,'MakeNameUnique','on');
    end
end

function updateLibraryLinks(blockHandle,blockPath,sourcePath)
    sourcePath=updatePathForSourceTestHarness(sourcePath);
    blockPath=updatePathForTargetTestHarness(blockPath);

    updateLinkPaths(blockHandle,sourcePath,blockPath);
    updateInternalLinksInVariantSubsystem(blockHandle,sourcePath,blockPath);
end

function path=updatePathForSourceTestHarness(path)
    if exist('slxmlcomp.internal.testharness.MemoryNames','class')~=0
        rootPath=slxmlcomp.internal.testharness.MemoryNames.getFileFromHarness(bdroot(path));
        if~isempty(rootPath)
            [~,rootName,~]=fileparts(rootPath);
            path=[rootName,'/',extractAfter(path,'/')];
        end
    end
end

function path=updatePathForTargetTestHarness(path)
    rootName=get_param(strtok(path,'/'),'OwnerBDName');
    if~isempty(rootName)
        path=[rootName,'/',extractAfter(path,'/')];
    end
end

function updateLinkPaths(blockHandle,sourcePath,newBlock)


    libdata=libinfo(blockHandle,'FollowLinks','off','MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices);
    for libIndex=1:length(libdata)
        if strcmp(libdata(libIndex).LinkStatus,'inactive')
            ancestorBlock=get_param(libdata(libIndex).Block,'AncestorBlock');
            updatePathsToInactiveLinks(libdata(libIndex).Block,ancestorBlock,sourcePath,newBlock);

        elseif~strcmp(libdata(libIndex).LinkStatus,'unresolved')&&...
            strcmp(get_param(libdata(libIndex).ReferenceBlock,'LinkStatus'),'inactive')
            set_param(libdata(libIndex).Block,'LinkStatus','inactive');
            ancestorBlock=get_param(libdata(libIndex).ReferenceBlock,'AncestorBlock');
            updatePathsToInactiveLinks(libdata(libIndex).Block,ancestorBlock,sourcePath,newBlock);

        else
            updatePathsToInternalLinks(libdata(libIndex),sourcePath,newBlock)
        end
    end
end

function updatePathsToInactiveLinks(blockName,ancestorBlock,sourcePath,newBlock)

    [libraryPath,relativePath]=strtok(ancestorBlock,'/');
    if strcmp(libraryPath,bdroot(sourcePath))

        newBlockRoot=strtok(newBlock,'/');
        set_param(...
        blockName,...
        'AncestorBlock',...
        [newBlockRoot,relativePath]...
        );
    else

        set_param(...
        blockName,...
        'AncestorBlock',...
ancestorBlock...
        );
    end
end

function updatePathsToInternalLinks(libdata,sourcePath,newBlock)

    [libraryPath,relativePath]=strtok(libdata.ReferenceBlock,'/');
    if strcmp(libraryPath,bdroot(sourcePath))
        newBlockRoot=strtok(newBlock,'/');
        set_param(...
        libdata.Block,...
        'ReferenceBlock',...
        [newBlockRoot,relativePath]...
        );
    end
end

function updateInternalLinksInVariantSubsystem(blockHandle,sourcePath,blockPath)
    params=get_param(blockHandle,'ObjectParameters');
    if isfield(params,'Variant')&&strcmp(get_param(blockHandle,'Variant'),'on')
        variants=get_param(blockHandle,'Variants');
        for variantIndex=1:length(variants)
            updateLinkPaths(...
            variants(variantIndex).BlockName,...
            sourcePath,...
blockPath...
            );
        end
    end
end


function modifiedObjects=i_MergeParameter(type,mergeActionData)


    modifiedObjects=java.util.ArrayList;


    srcNode=mergeActionData.getFromNode();
    srcPath=char(srcNode.getNodePath());
    dstNode=mergeActionData.getToNode();
    dstPath=char(dstNode.getNodePath());

    paramName=char(mergeActionData.getParameterName());
    switch type
    case 'Annotation'
        srcObj=slxmlcomp.internal.annotation.find(...
        slxmlcomp.internal.annotation.highlightPathToStruct(srcPath)...
        );
        dstObj=slxmlcomp.internal.annotation.find(...
        slxmlcomp.internal.annotation.highlightPathToStruct(dstPath)...
        );
    case{'Model','Library','Block','Subsystem','ModelSettings','Object','ConfigManagerSettings','chart'}
        srcObj=i_GetObject(srcPath);
        dstObj=i_GetObject(dstPath);
    case 'Mask'
        srcObj=i_GetObject(srcPath);
        dstObj=i_GetObject(dstPath);
        paramName=['Mask',paramName];
    case{'Line','Branch'}
        srcObj=slxmlcomp.internal.line.getLineUnique(...
        slxmlcomp.internal.line.linePathToStruct(srcPath)...
        );
        dstObj=slxmlcomp.internal.line.getLineUnique(...
        slxmlcomp.internal.line.linePathToStruct(dstPath)...
        );
    otherwise
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end

    oldVal=warning('off','Simulink:modelReference:ParameterOnlyValidWhenModelIsCompiledAndTopModel');
    restoreWarning=onCleanup(@()warning(oldVal));



    dstSFObj=[];
    if strcmp('Name',paramName)



        object=get_param(dstObj,'Object');
        dstSFObj=Stateflow.SLINSF.SimfcnMan.getSLFunction(object);

        lines=i_GetAffectedLines(mergeActionData.getAffectedNodes());
    end



    srcHL=i_ClearHighlighting(srcObj);
    restoreSrcHL=onCleanup(@()i_RestoreHighlighting(srcObj,srcHL));
    dstHL=i_ClearHighlighting(dstObj);
    restoreDstHL=onCleanup(@()i_RestoreHighlighting(dstObj,dstHL));




    srcParamValue=get_param(srcObj,paramName);


    oldDstParams=i_GetObjectParameters(dstObj);

    if isempty(dstSFObj)
        if strcmp('Annotation',type)&&strcmp('Name',paramName)
            interpreter=get_param(srcObj,'Interpreter');
            set_param(dstObj,'Interpreter',interpreter);
        end
        set_param(dstObj,paramName,srcParamValue);
    else
        dstSFObj.Name=srcParamValue;
    end


    newDstParams=i_GetObjectParameters(dstObj);


    filters={};




    paramDifferences=i_GetParameterDifferences(newDstParams,oldDstParams,filters);
    if isempty(paramDifferences)||isempty(find(ismember(paramDifferences(:,1),paramName),1))

        paramDifferences=[paramDifferences;{paramName,...
        slxmlcomp.internal.convertToString(get_param(srcObj,paramName)),...
        slxmlcomp.internal.convertToString(get_param(dstObj,paramName))}];
    end


    parameterUpdater=mergeActionData.getParameterUpdater();
    slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,srcNode,paramDifferences,true,true,dstNode);
    targetChoice=mergeActionData.getFromSide();
    parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
    slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,dstNode,paramDifferences,true,true,srcNode,targetChoice,parameterNameToDiffMap);


    if strcmp(paramName,'Name')
        i_UpdateLines(lines,mergeActionData);
        arrayfun(@(x)modifiedObjects.add(x.jLine),lines);
    end

end






function i_AddLineHandleParameter(node,line)
    import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightArtificialParameter;



    node.addParameter(LightweightArtificialParameter('Handle',mat2str(line.Handle,17),false));
end


function[line,message]=i_AddLineUsingPoints(srcLine,dstPath,name,portNum,isDst)
    line=[];
    message='';

    blockHandle=get_param([dstPath,'/',name],'handle');
    portHandle=iGetPortHandleFromPortNum(portNum,isDst,blockHandle);


    points=get_param(srcLine.Handle,'Points');
    points=points';


    loc=get_param(portHandle,'Position');

    if isDst
        points(numel(points)-1)=loc(1);
        points(numel(points))=loc(2);
    else
        points(1)=loc(1);
        points(2)=loc(2);
    end
    points=points';
    try
        lineHandle=add_line(dstPath,points);
        line=slxmlcomp.internal.line.Line(lineHandle);
    catch E
        message=E.message;
    end
end


function oldVal=i_ClearHighlighting(obj)
    oldVal=get_param(obj,'HiliteAncestors');
    set_param(obj,'HiliteAncestors','none');
end


function[line,msgIn]=i_ConnectChildren(srcNode,dstNode,children,msgIn,differences,partnerSource,sourceSource,visitedLines)

    line=[];


    for i=1:numel(children)
        currentChild=children(i);
        grandChildren=children(i).Children;
        if isempty(grandChildren)||any(arrayfun(@(x)isequal(x,currentChild),visitedLines))

            [returnLine,message]=i_ConnectLine(srcNode,dstNode,children(i),[],differences,partnerSource,sourceSource);


            if~isempty(returnLine)
                line=returnLine;
            end


            if~isempty(message)
                if isempty(msgIn)
                    msgIn=message;
                else
                    msgIn=sprintf('%s\n%s',msgIn,message);
                end
            end
        else
            visitedLines=[visitedLines;children];

            [line,msgIn]=i_ConnectChildren(srcNode,dstNode,grandChildren,msgIn,differences,partnerSource,sourceSource,visitedLines);
        end
    end
end


function[line,message]=i_ConnectLine(srcNode,dstNode,child,lines,differences,targetSource,sourceSource)

    line=[];
    message='';

    dstPath=char(dstNode.getNodePath());


    srcBlockName=child.SrcBlockName;
    dstBlockName=child.DstBlockName;

    hasSrcBlock=~isempty(srcBlockName);
    hasDstBlock=~isempty(dstBlockName);


    srcName=i_FindMatchedName(srcNode,dstNode,srcBlockName,differences,targetSource);
    dstName=i_FindMatchedName(srcNode,dstNode,dstBlockName,differences,targetSource);

    if(hasSrcBlock&&isempty(srcName))||(hasDstBlock&&isempty(dstName))
        if isempty(srcName)
            blockNameToUse=srcBlockName;
        else
            blockNameToUse=dstBlockName;
        end
        message=slxmlcomp.internal.getMessage('slxmlcomp.merge.addlineblocknoexist',srcBlockName,dstBlockName,[dstPath,'/',blockNameToUse]);
        return
    end

    if hasSrcBlock&&hasDstBlock


        srcPort=child.SrcPortNumber;
        dstPort=child.DstPortNumber;


        [success,message]=i_VerifyLineCanConnect(dstPath,srcName,dstName,srcName,srcPort,false);


        if~success
            return
        end


        [success,message]=i_VerifyLineCanConnect(dstPath,srcName,dstName,dstName,dstPort,true,srcNode,lines,differences,sourceSource);


        if~success
            return
        end

        src=[srcName,'/',num2str(srcPort)];
        dst=[dstName,'/',num2str(dstPort)];
        lineHandle=add_line(dstPath,src,dst,'autorouting','on');
        line=slxmlcomp.internal.line.Line(lineHandle);

    elseif~hasSrcBlock&&~hasDstBlock

        lineHandle=add_line(dstPath,get_param(child.Handle,'Points'));
        line=slxmlcomp.internal.line.Line(lineHandle);

    elseif~hasSrcBlock&&hasDstBlock




        dstPort=child.DstPortNumber;
        [success,message]=i_VerifyLineCanConnect(dstPath,' ',dstName,dstName,dstPort,true);


        if~success
            return
        end




        [line,message]=i_AddLineUsingPoints(child,dstPath,dstName,dstPort,true);

    elseif hasSrcBlock&&~hasDstBlock




        srcPort=child.SrcPortNumber;
        [success,message]=i_VerifyLineCanConnect(dstPath,srcName,' ',srcName,srcPort,false);


        if~success
            return
        end




        [line,message]=i_AddLineUsingPoints(child,dstPath,srcName,srcPort,false);
    end
end


function node=i_CreateNode(srcNode)
    node=srcNode.copy();
end


function name=i_FindMatchedName(srcNode,dstNode,blockName,differences,partnerSource)

    name='';


    if isempty(blockName)
        return
    end


    srcParent=srcNode.getParent();
    child=[];
    for i=0:srcParent.getChildren().size()-1
        tempChild=srcParent.getChildren().get(i);
        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        nameParameter=LightweightNodeUtils.getParameter(tempChild,'Name');
        if isempty(nameParameter)
            continue
        end
        if strcmp(blockName,char(nameParameter.getValue()))
            child=tempChild;
            break
        end
    end


    if isempty(child)

        name=blockName;
        return
    end


    difference=differences.getDifferenceForSnippet(child);
    partner=difference.getSnippet(partnerSource);
    if isempty(partner)||(dstNode~=partner.getParent())

        return
    end


    name=char(partner.getName());
end


function lines=i_GetAffectedLines(jLines)
    iterator=jLines.iterator();
    lines=[];
    while iterator.hasNext()
        jLine=iterator.next();





        if jLine.getTagName().equals("transition")
            continue;
        end


        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        handleParam=LightweightNodeUtils.getParameter(jLine,'Handle');
        if~isempty(handleParam)
            lineHandle=str2double(handleParam.getValue());
            if ishandle(lineHandle)
                slLine=slxmlcomp.internal.line.Line(lineHandle);
                lines=addLine(lines,slLine,jLine);
                continue
            end
        end


        lineHandle=slxmlcomp.internal.line.getLine(char(jLine.getNodePath()));


        numHandles=numel(lineHandle);
        if numHandles==1
            slLine=slxmlcomp.internal.line.Line(lineHandle);


            if~slLine.hasChildren()&&ishandle(lineHandle)
                lines=addLine(lines,slLine,jLine);
            else

                branch=i_FindBranch(slLine,jLine,[]);
                if~isempty(branch)&&ishandle(branch.Handle)
                    lines=addLine(lines,branch,jLine);
                end
            end
            continue
        end



        for i=1:numHandles
            slLine=slxmlcomp.internal.line.Line(lineHandle(i));



            if~slLine.hasChildren()
                if i_MatchLineOnPoints(slLine,jLine)&&ishandle(slLine.Handle)
                    lines=addLine(lines,slLine,jLine);
                    break
                end
            else
                branch=i_FindBranch(slLine,jLine,[]);
                if~isempty(branch)&&ishandle(branch.Handle)
                    lines=addLine(lines,branch,jLine);
                end
            end

        end

    end

    function lines=addLine(lines,slLine,jLine)
        line=struct('slLine',slLine,'jLine',jLine);
        lines=[lines;line];
    end

    function foundBranch=i_FindBranch(slLine,jLine,branchesSearched)

        foundBranch=[];
        branchesSearched=[branchesSearched,slLine];
        srcMatch=i_MatchLineOnSource(slLine,jLine);
        pointsMatch=i_MatchLineOnPoints(slLine,jLine);
        if srcMatch&&pointsMatch
            foundBranch=slLine;
            return
        end

        if pointsMatch


            import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.line.LineUtils;
            import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
            lineSrc=char(LightweightNodeUtils.getParameterValue(jLine,LineUtils.SRC_BLOCK_PARAMETER_NAME));
            lineDst=char(LightweightNodeUtils.getParameterValue(jLine,LineUtils.DST_BLOCK_PARAMETER_NAME));
            if isempty(lineSrc)&&isempty(lineDst)&&pointsMatch
                foundBranch=slLine;
                return
            end
        end


        dstMatch=i_MatchLineOnDestination(slLine,jLine);
        if dstMatch
            foundBranch=slLine;
            return
        end


        children=slLine.Children;
        for j=1:numel(children)
            child=children(j);
            if~isequal(child,slLine)&&~any(arrayfun(@(x)(isequal(x,child)),branchesSearched))
                foundBranch=i_FindBranch(child,jLine,branchesSearched);
                if~isempty(foundBranch)
                    return
                end
            end
        end
    end

end


function[vals,names]=i_GetFilteredValues(values,additionalFilters)

    names=fieldnames(values);
    vals=struct2cell(values);

    idx=[];


    if nargin==2
        for i=1:numel(additionalFilters)
            idx=[idx;find(strcmp(names,additionalFilters(i)))];%#ok<AGROW>
        end
    end


    vals(idx)=[];
    names(idx)=[];
end


function line=i_GetLine(linePath)
    try
        lineHandle=slxmlcomp.internal.line.getLineUnique(...
        slxmlcomp.internal.line.linePathToStruct(linePath)...
        );
        line=slxmlcomp.internal.line.Line(lineHandle);
    catch E %#ok<NASGU>  Catch the error and re-thrown in the merge context.

        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletolocateline',linePath));
    end
end


function object=i_GetObject(path)
    object=get_param(path,'Handle');
    if numel(object)~=1||~ishandle(object)
        error(slxmlcomp.internal.getMessage('slxmlcomp.merge.unabletomerge'));
    end
end


function params=i_GetObjectParameters(obj)
    object=get_param(obj,'Object');
    params=struct(object);
end


function differences=i_GetParameterDifferences(values1,values2,filters)

    [values1,names1]=i_GetFilteredValues(values1,filters);
    [values2,names2]=i_GetFilteredValues(values2,filters);

    differences=slxmlcomp.internal.merge.getDifferences(names1,values1,names2,values2);
end


function matched=i_MatchLineOnPoints(slLine,jLine)
    matched=false;
    import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.line.LineUtils;
    import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
    pointsToMatch=char(LightweightNodeUtils.getParameterValue(jLine,LineUtils.POINTS_PARAMETER_NAME));
    if isempty(pointsToMatch)
        return
    end

    points=slLine.Points;
    if strcmp(points,pointsToMatch)
        matched=true;
    end
end


function matched=i_MatchLine(slLine,jLine,srcOrDst)
    matched=false;
    import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
    nameToMatch=char(LightweightNodeUtils.getParameterValue(jLine,[srcOrDst,'Block']));
    if isempty(nameToMatch)
        return
    end

    name=slLine.([srcOrDst,'BlockName']);
    port=slLine.([srcOrDst,'PortNumberStr']);
    portToMatch=char(LightweightNodeUtils.getParameterValue(jLine,[srcOrDst,'Port']));
    if strcmp(nameToMatch,name)&&strcmp(portToMatch,port)
        matched=true;
    end
end


function matched=i_MatchLineOnDestination(slLine,jLine)
    matched=i_MatchLine(slLine,jLine,'Dst');
end


function matched=i_MatchLineOnSource(slLine,jLine)
    matched=i_MatchLine(slLine,jLine,'Src');
end


function i_RestoreHighlighting(obj,hilite)
    set_param(obj,'HiliteAncestors',hilite);
end


function i_UpdateLines(lines,mergeActionData)
    for ii=1:numel(lines)
        line=lines(ii);
        slLine=line.slLine;
        jLine=line.jLine;


        update={};

        import com.mathworks.toolbox.rptgenslxmlcomp.comparison.node.customization.type.line.LineUtils;

        if~slLine.hasParent()
            update=[update;{LineUtils.SRC_BLOCK_PARAMETER_NAME,slLine.SrcBlockName,''}];%#ok<AGROW>
            update=[update;{LineUtils.SRC_PORT_PARAMETER_NAME,slLine.SrcPortNumberStr,''}];%#ok<AGROW>
        end


        if~slLine.hasChildren()
            update=[update;{LineUtils.DST_BLOCK_PARAMETER_NAME,slLine.DstBlockName,''}];%#ok<AGROW>
            update=[update;{LineUtils.DST_PORT_PARAMETER_NAME,slLine.DstPortNumberStr,''}];%#ok<AGROW>
        end

        update=[update;{LineUtils.POINTS_PARAMETER_NAME,slLine.Points,''}];%#ok<AGROW>
        update=[update;{'Handle',num2str(slLine.Handle),''}];%#ok<AGROW>


        update=i_FilterUnchangedParameters(jLine,update);


        differences=mergeActionData.getDiffSet();
        source=mergeActionData.getFromSource();
        difference=differences.getDifferenceForSnippet(jLine);
        partner=difference.getSnippet(source);
        targetChoice=mergeActionData.getFromSide();
        parameterNameToDiffMap=mergeActionData.getParameterNameToDifferenceMap();
        parameterUpdater=mergeActionData.getParameterUpdater();
        slxmlcomp.internal.merge.updateNodeParameters(parameterUpdater,jLine,update,false,false,partner,targetChoice,parameterNameToDiffMap);


        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        handleParam=LightweightNodeUtils.getParameter(jLine,'Handle');
        if isempty(handleParam)
            i_AddLineHandleParameter(jLine,slLine);
        end
    end
end


function parameters=i_FilterUnchangedParameters(dstLine,parameters)
    offset=0;
    numParams=size(parameters,1);
    for i=1:numParams
        index=i+offset;
        name=parameters{index,1};
        value=parameters{index,2};
        import com.mathworks.toolbox.rptgenxmlcomp.comparison.node.LightweightNodeUtils;
        srcValue=LightweightNodeUtils.getParameterValue(dstLine,name);
        if~isempty(srcValue)&&strcmp(srcValue,value)
            parameters(index,:)=[];
            offset=offset-1;
        end
    end
end


function[success,message]=i_VerifyLineCanConnect(dstPath,srcName,dstName,name,portNum,isDst,srcNode,lines,differences,sourceSource)
    success=false;
    message='';
    fullBlockPath=[dstPath,'/',name];


    try
        blockHandle=get_param(fullBlockPath,'handle');
    catch E %#ok<NASGU> Throw custom error when object doesn't exist
        message=slxmlcomp.internal.getMessage('slxmlcomp.merge.addlineblocknoexist',srcName,dstName,fullBlockPath);
        return
    end


    portHandle=iGetPortHandleFromPortNum(portNum,isDst,blockHandle);


    if isempty(portHandle)
        message=i_GetNoPortMessage(srcName,dstName,fullBlockPath,portNum);
        return
    end


    if~isDst
        success=true;
        return
    end


    line_handle=get_param(portHandle,'Line');
    if line_handle>0


        if~i_IsAlreadyConnected(line_handle,srcName,dstName)


            message=slxmlcomp.internal.getMessage('slxmlcomp.merge.addlineportconnected',srcName,dstName,fullBlockPath,portNum);
        else



            if~isa(differences,'com.mathworks.comparisons.difference.MapBackedTargetDifferenceSet')&&...
                ~isa(differences,'com.mathworks.comparisons.filter.model.FilteredDifferenceSet')&&...
                ~isempty(srcNode)&&~isempty(lines)
                lineIndex=find(arrayfun(@(x)x.slLine.Handle==line_handle,lines));
                if~isempty(lineIndex)
                    jLine=lines(lineIndex).jLine;
                    targetDifference=differences.getDifferenceForSnippet(jLine);
                    sourceDifference=differences.getDifferenceForSnippet(srcNode);
                    sourceDifference.setSnippet(sourceSource,[]);
                    targetDifference.setSnippet(sourceSource,srcNode);
                    import com.mathworks.comparisons.util.Side;
                    targetDifference.setTargetSnippetChoice(Side.RIGHT,jLine);
                    jLine.setMerged(true);
                    srcNode.setMerged(true);
                end
            end
        end
        return
    end
    function connected=i_IsAlreadyConnected(line,src,dst)
        currentDst=get_param(line,'DstBlock');
        lineParent=get_param(line,'LineParent');
        if lineParent>0
            line=lineParent;
        end

        currentSrc=get_param(line,'SrcBlock');
        connected=~isempty(src)&&strcmp(currentSrc,src)&&...
        ~isempty(dst)&&strcmp(currentDst,dst);
    end

    function msg=i_GetNoPortMessage(srcName,dstName,fullBlockPath,portNum)
        msg=slxmlcomp.internal.getMessage('slxmlcomp.merge.addlineportnoexist',srcName,dstName,fullBlockPath,portNum);
    end

    success=true;
end

function portHandle=iGetPortHandleFromPortNum(portNum,isDst,blockHandle)
    portHandles=get_param(blockHandle,'PortHandles');
    portHandle=[];
    if isNamedPort(portNum)
        portHandle=portHandles.(capitalizeFirstLetter(portNum));
        return
    end

    if isInport(portNum,isDst,portHandles)
        portHandle=portHandles.Inport(portNum);
        return
    end

    if isOutport(portNum,isDst,portHandles)
        portHandle=portHandles.Outport(portNum);
        return
    end


    function namedPort=isNamedPort(portNum)
        namedPorts={'enable','state','trigger','ifaction','Reset'};
        namedPort=ischar(portNum)&&ismember(portNum,namedPorts);
    end

    function validInport=isInport(portNum,isDst,ports)
        validInport=isDst&&portNum>0&&portNum<=numel(ports.Inport);
    end

    function validOutport=isOutport(portNum,isDst,ports)
        validOutport=~isDst&&portNum>0&&portNum<=numel(ports.Outport);
    end

    function newPortNum=capitalizeFirstLetter(portNum)
        newPortNum=strcat(upper(portNum(1)),portNum(2:end));
    end

end

