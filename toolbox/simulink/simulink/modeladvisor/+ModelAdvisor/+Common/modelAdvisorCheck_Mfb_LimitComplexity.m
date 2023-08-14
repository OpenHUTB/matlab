



function[bResultStatus,resultDescription,resultHandles]=...
    modelAdvisorCheck_Mfb_LimitComplexity(system,checkParameter)

    MSG=checkParameter.xlateTagPrefix;

    bResultStatus=true;
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    sysObj=get_param(system,'Object');
    resultDescription={};
    resultHandles={};

    resultList=validateCheckParameters(checkParameter);
    if~isempty(resultList)
        bResultStatus=false;
        mdladvObj.setCheckErrorSeverity(1);
        resultHandles{end+1}=[];
        resultDescription{end+1}=[...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_CheckText')),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text('<font color="red"><b>'),...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_Error')),...
        ModelAdvisor.Text('</b></font>'),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_InvalidCheckParameter')),...
        resultList];
        return
    end


    blockTable=prepareBlockTable(checkParameter);
    fileTable=prepareFileTable(checkParameter);







    fileDependencies=getFileDependencies(bdroot(system));

    emcObjects=sysObj.find('-isa','Stateflow.EMChart');
    emcObjects=sortEmObjectsBySid(emcObjects);
    emfObjects=sysObj.find('-isa','Stateflow.EMFunction');
    emfObjects=sortEmObjectsBySid(emfObjects);
    emObjects=[emcObjects;emfObjects];


    if isempty(emObjects)&&isempty(fileDependencies.Nodes.Name)
        bResultStatus=true;
        blockTable.setSubResultStatus('Pass');
        blockTable.setSubResultStatusText(...
        TEXT(MSG,'Himl0003_PassNoMatlabFunctionBlocks'));
        resultDescription{end+1}=blockTable;
        resultHandles{end+1}=[];
        return
    end

    emObjects=mdladvObj.filterResultWithExclusion(emObjects);

    bResult=createBlockTable(blockTable,emObjects,checkParameter);
    if bResult==false
        bResultStatus=false;
    end

    bResult=createFileTable(fileTable,system,checkParameter,MSG);
    if bResult==false
        bResultStatus=false;
    end

    finalizeResults(bResultStatus,blockTable,fileTable,MSG);

    resultDescription{end+1}=blockTable;
    resultHandles{end+1}=[];
    resultDescription{end+1}=fileTable;
    resultHandles{end+1}=[];

end

function emObjectsSorted=sortEmObjectsBySid(emObjects)

    sidTable=cell(numel(emObjects),1);
    for i=1:numel(emObjects)
        thisObject=emObjects(i);
        sidTable{i}=Simulink.ID.getSID(thisObject);
    end
    [~,index]=sort(sidTable);
    emObjectsSorted=emObjects(index);
end

function string=TEXT(MSG,ID)
    string=DAStudio.message([MSG,ID]);
end

function resultList=validateCheckParameters(checkParameter)

    msgGroup=checkParameter.xlateTagPrefix;
    linesOfCode=checkParameter.linesOfCode;
    densityOfComments=checkParameter.densityOfComments;
    cyclomaticComplexity=checkParameter.cyclomaticComplexity;

    if isnan(linesOfCode)
        isLinesOfCodeValid=false;
    else
        if linesOfCode~=fix(linesOfCode)
            isLinesOfCodeValid=false;
        else
            if linesOfCode<1
                isLinesOfCodeValid=false;
            else
                isLinesOfCodeValid=true;
            end
        end
    end

    if isnan(densityOfComments)
        isDensityOfCommentsValid=false;
    else
        if densityOfComments<0||densityOfComments>1
            isDensityOfCommentsValid=false;
        else
            isDensityOfCommentsValid=true;
        end
    end

    if isnan(cyclomaticComplexity)
        isCyclomaticComplexityValid=false;
    else
        if cyclomaticComplexity~=fix(cyclomaticComplexity)
            isCyclomaticComplexityValid=false;
        else
            if cyclomaticComplexity<1
                isCyclomaticComplexityValid=false;
            else
                isCyclomaticComplexityValid=true;
            end
        end
    end

    areAllParameterValid=isLinesOfCodeValid&&...
    isDensityOfCommentsValid&&isCyclomaticComplexityValid;
    if areAllParameterValid
        resultList=[];
    else
        resultList=ModelAdvisor.List;
        if~isLinesOfCodeValid
            resultList.addItem(DAStudio.message(...
            [msgGroup,'Himl0003_InvalidLinesOfCodeParameter']));
        end
        if~isDensityOfCommentsValid
            resultList.addItem(DAStudio.message(...
            [msgGroup,'Himl0003_InvalidDensityOfCommentsParameter']));
        end
        if~isCyclomaticComplexityValid
            resultList.addItem(DAStudio.message(...
            [msgGroup,'Himl0003_InvalidCyclomaticComplexityParameter']));
        end
    end

end

function blockTable=prepareBlockTable(checkParameter)
    msgGroup=checkParameter.xlateTagPrefix;
    blockTable=ModelAdvisor.FormatTemplate('TableTemplate');
    blockTable.setSubBar(false);
    blockTable.setCheckText(DAStudio.message([msgGroup,'Himl0003_CheckText']));
    blockTable.setColTitles({...
    DAStudio.message([msgGroup,'Himl0003_BlockTableHead1']),...
    DAStudio.message([msgGroup,'Himl0003_BlockTableHead2']),...
    DAStudio.message([msgGroup,'Himl0003_BlockTableHead3'])});



end

function fileTable=prepareFileTable(checkParameter)
    msgGroup=checkParameter.xlateTagPrefix;
    fileTable=ModelAdvisor.FormatTemplate('TableTemplate');
    fileTable.setSubBar(false);
    fileTable.setColTitles({...
    DAStudio.message([msgGroup,'Himl0003_FileTableHead1']),...
    DAStudio.message([msgGroup,'Himl0003_FileTableHead2']),...
    DAStudio.message([msgGroup,'Himl0003_FileTableHead3'])});
end

function finalizeResults(bResultStatus,blockTable,fileTable,MSG)

    if bResultStatus

        blockTable.setSubResultStatus('Pass');
        blockTable.setSubResultStatusText([...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_Pass1')),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_Pass2')),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.LineBreak,...
        createLegend(MSG)]);

    else

        blockTable.setSubResultStatus('Warn');
        blockTable.setSubResultStatusText([...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_Fail1')),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_Fail2')),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.LineBreak,...
        createLegend(MSG)]);

        actionText1=ModelAdvisor.Text(TEXT(MSG,'Himl0003_ActionText1'));
        actionList=ModelAdvisor.List();
        actionList.addItem(TEXT(MSG,'Himl0003_ActionItem1'));
        actionList.addItem(TEXT(MSG,'Himl0003_ActionItem2'));

        fileTable.setRecAction([actionText1,actionList]);

    end

end

function bResultStatus=createBlockTable(blockTable,emObjects,checkParameter)
    bResultStatus=true;
    for idx=1:length(emObjects)

        emObject=emObjects(idx);

        metrics=getCodeMetrics('code',emObject.Script);

        assert(~isempty(metrics.functions),[...
        DAStudio.message('ModelAdvisor:hism:himl_invalid_syntax'),' '...
        ,class(emObject),': ',emObject.Path]);

        [blockDetailsTable,functionDetailsTable,numIssues]=...
        createDetailsTables(metrics,checkParameter);

        if numIssues>0
            bResultStatus=false;
        end

        switch class(emObject)
        case 'Stateflow.EMChart'
            SID=Simulink.ID.getSID(emObject);
        case 'Stateflow.EMFunction'

            SID=Simulink.ID.getSID(emObject);
        end
        firstCol=ModelAdvisor.Text(SID);

        secondCol=blockDetailsTable;
        thirdCol=functionDetailsTable;
        blockTable.addRow({firstCol,secondCol,thirdCol});

    end
end

function bResultStatus=createFileTable(...
    fileTable,system,checkParameter,MSG)

    bResultStatus=true;

    [allExternalFunctions,referenceLocations]=...
    getExternalFiles(system);

    for idx=1:length(allExternalFunctions)

        fileName=allExternalFunctions{idx};
        calledBy=referenceLocations{idx};
        usageList=createUsageList(calledBy);








        [~,~,ext]=fileparts(fileName);

        if exist(fileName,'file')&&(strcmp(ext,'.m')||strcmp(ext,'.mlx'))
            fileLink=createMatlabFileLink(fileName);
            metrics=getCodeMetrics('file',fileName);
            [blockDetailsTable,functionDetailsTable,numIssues]=...
            createDetailsTables(metrics,checkParameter);
            if numIssues>0
                bResultStatus=false;
            end
        else
            [~,onlyFileName,~]=fileparts(fileName);

            if strcmp(onlyFileName,fileName)


                fileLink=[fileName,'.m'];
            else




                fileLink=[onlyFileName,'.m'];
            end
            blockDetailsTable=TEXT(MSG,'Himl0003_ExtNotFound');
            functionDetailsTable='-';
            bResultStatus=false;
        end

        firstCol=[...
        ModelAdvisor.Text(fileLink),...
        ModelAdvisor.LineBreak,...
        ModelAdvisor.Text(TEXT(MSG,'Himl0003_UsedBy')),...
        ModelAdvisor.LineBreak,...
usageList...
        ];
        secondCol=blockDetailsTable;
        thirdCol=functionDetailsTable;
        if isempty(thirdCol)

            thirdCol=ModelAdvisor.Text(TEXT(MSG,'Himl0003_NoFunctionsFound'));
        else
            thirdCol=functionDetailsTable;
        end
        fileTable.addRow({firstCol,secondCol,thirdCol});

    end

end

function[allExternalFunctions,referenceLocations]=...
    getExternalFiles(system)



    DependencySet=dependencies.internal.analyze(which(bdroot(system)),...
    "Include",["MATLABFcn","StateflowMATLABFcn"],...
    "Traverse","Test",...
    "AnalyzeUnsaved",true);


    Edges=DependencySet.Edges;
    filters=cellfun(@(c)contains(c,system),Edges.UpstreamComponent);
    allExternalFunctions=unique(Edges.EndNodes(find(filters),2));
    referenceLocations={};
    for idxFun=1:length(allExternalFunctions)
        tmp_referenceLocations={};
        for idxRef=1:height(Edges)
            if strcmp(Edges.EndNodes{idxRef,2},allExternalFunctions{idxFun})&&filters(idxRef)
                tmp_referenceLocations{end+1}=Edges.UpstreamComponent{idxRef};
            end
        end
        referenceLocations{end+1}=tmp_referenceLocations;
    end

end

function usageList=createUsageList(calledBy)




    usageList=ModelAdvisor.List;
    for refIdx=1:numel(calledBy)
        item=calledBy{refIdx};
        colonPos=regexp(item,':\d+$','once');
        if isempty(colonPos)

            usageList.addItem(item);
        else

            block=item(1:colonPos-1);
            SSID=item(colonPos+1:end);
            blockSID=Simulink.ID.getSID(block);
            SID=[blockSID,':',SSID];
            if Simulink.ID.isValid(SID)
                usageList.addItem(SID);
            else
                usageList.addItem(item);
            end
        end
    end
end

function[blockDetailsTable,functionDetailsTable,numIssues]=...
    createDetailsTables(metrics,checkParameter)

    [blockDetailsTable,numBlockIssues]=createBlockDetailsTable(...
    metrics,checkParameter);

    [functionDetailsTable,numFunctionIssues]=createFunctionDetailsTable(...
    metrics,checkParameter);

    numIssues=numBlockIssues+numFunctionIssues;

end

function resultObjects=createLegend(MSG)

    abbreviationLOC=TEXT(MSG,'Himl0003_ColumnHeaderLOC');
    abbreviationELOC=TEXT(MSG,'Himl0003_ColumnHeaderELOC');
    abbreviationCLOC=TEXT(MSG,'Himl0003_ColumnHeaderCLOC');
    abbreviationDC=TEXT(MSG,'Himl0003_ColumnHeaderDC');
    abbreviationCYC=TEXT(MSG,'Himl0003_ColumnHeaderCYC');

    explanationLOC=TEXT(MSG,'Himl0003_ExplanationLOC');
    explanationELOC=TEXT(MSG,'Himl0003_ExplanationELOC');
    explanationCLOC=TEXT(MSG,'Himl0003_ExplanationCLOC');
    explanationDC=TEXT(MSG,'Himl0003_ExplanationDC');
    explanationCYC=TEXT(MSG,'Himl0003_ExplanationCYC');

    formatPrefix=ModelAdvisor.Text('<font size="-1">');
    formatPostfix=ModelAdvisor.Text('</font>');

    headerText=ModelAdvisor.Text(TEXT(MSG,'Himl0003_AbbreviationListHeader'));

    abbreviationList=ModelAdvisor.List;
    abbreviationList.addItem([abbreviationLOC,' : ',explanationLOC]);
    abbreviationList.addItem([abbreviationELOC,' : ',explanationELOC]);
    abbreviationList.addItem([abbreviationCLOC,' : ',explanationCLOC]);
    abbreviationList.addItem([abbreviationDC,' : ',explanationDC]);
    abbreviationList.addItem([abbreviationCYC,' : ',explanationCYC]);

    resultObjects=[formatPrefix,headerText,abbreviationList,formatPostfix];

end

function[blockDetailsTable,numIssues]=createBlockDetailsTable(...
    metrics,checkParameter)

    numIssues=0;
    MSG=checkParameter.xlateTagPrefix;

    columnHeaderLOC=TEXT(MSG,'Himl0003_ColumnHeaderLOC');
    columnHeaderELOC=TEXT(MSG,'Himl0003_ColumnHeaderELOC');
    columnHeaderCLOC=TEXT(MSG,'Himl0003_ColumnHeaderCLOC');
    columnHeaderDC=TEXT(MSG,'Himl0003_ColumnHeaderDC');

    columnValueLOC=sprintf('%d',metrics.totalLinesOfCode);
    columnValueELOC=sprintf('%d',metrics.effectiveLinesOfCode);
    columnValueCLOC=sprintf('%d',metrics.commentLinesOfCode);
    columnValueDC=sprintf('%5.3f',metrics.densityOfComments);

    densityOfCommentsViolation=...
    metrics.densityOfComments<checkParameter.densityOfComments;
    if densityOfCommentsViolation
        numIssues=numIssues+1;
        columnValueDC=['<font color="red">',columnValueDC,'</font>'];
    end

    blockDetailsTable=ModelAdvisor.Table(1,4);
    blockDetailsTable.setColHeading(1,columnHeaderLOC);
    blockDetailsTable.setColHeading(2,columnHeaderELOC);
    blockDetailsTable.setColHeading(3,columnHeaderCLOC);
    blockDetailsTable.setColHeading(4,columnHeaderDC);
    blockDetailsTable.setEntry(1,1,columnValueLOC);
    blockDetailsTable.setEntry(1,2,columnValueELOC);
    blockDetailsTable.setEntry(1,3,columnValueCLOC);
    blockDetailsTable.setEntry(1,4,columnValueDC);
end

function[functionDetailsTable,numIssues]=createFunctionDetailsTable(...
    metrics,checkParameter)

    numIssues=0;
    MSG=checkParameter.xlateTagPrefix;

    columnHeaderFCN=TEXT(MSG,'Himl0003_ColumnHeaderFCN');
    columnHeaderELOC=TEXT(MSG,'Himl0003_ColumnHeaderELOC');
    columnHeaderCYC=TEXT(MSG,'Himl0003_ColumnHeaderCYC');

    numFunctions=length(metrics.functions);

    if numFunctions==0


        functionDetailsTable=[];
    else
        functionDetailsTable=ModelAdvisor.Table(numFunctions,3);
        functionDetailsTable.setColHeading(1,columnHeaderFCN);
        functionDetailsTable.setColHeading(2,columnHeaderELOC);
        functionDetailsTable.setColHeading(3,columnHeaderCYC);

        for fcnIdx=1:numFunctions
            effectiveLinesOfCode=metrics.functions(fcnIdx).effectiveLinesOfCode;
            cyclomaticComplexity=metrics.functions(fcnIdx).cyclomaticComplexity;

            columnValueFCN=metrics.functions(fcnIdx).functionName;
            columnValueELOC=sprintf('%d',effectiveLinesOfCode);
            columnValueCYC=sprintf('%d',cyclomaticComplexity);

            effectiveLinesOfCodeViolation=...
            effectiveLinesOfCode>checkParameter.linesOfCode;
            cyclomaticComplexityViolation=...
            cyclomaticComplexity>checkParameter.cyclomaticComplexity;

            if effectiveLinesOfCodeViolation
                numIssues=numIssues+1;
                columnValueELOC=['<font color="red">',columnValueELOC,'</font>'];%#ok<AGROW> done only once
            end
            if cyclomaticComplexityViolation
                numIssues=numIssues+1;
                columnValueCYC=['<font color="red">',columnValueCYC,'</font>'];%#ok<AGROW> done only once
            end

            functionDetailsTable.setEntry(fcnIdx,1,columnValueFCN);
            functionDetailsTable.setEntry(fcnIdx,2,columnValueELOC);
            functionDetailsTable.setEntry(fcnIdx,3,columnValueCYC);

        end
    end

end

function metrics=getCodeMetrics(typeFlag,argument)
    mtreeObject=get_mtreeObject(typeFlag,argument);


    if~Advisor.Utils.isValidMtree(mtreeObject)
        metrics=struct('totalLinesOfCode',-1,'effectiveLinesOfCode',-1,...
        'commentLinesOfCode',-1,'densityOfComments',-1,'functions',[]);
        return;
    end

    checkCodeResults=get_checkCodeResults(typeFlag,argument);
    totalLinesOfCode=get_totalLinesOfCode(typeFlag,argument);

    noCodeNodes=mtreeObject.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
    codeNodes=mtreeObject.mtfind('~Member',noCodeNodes);
    functionNodes=mtreeObject.mtfind('Kind','FUNCTION');
    commentNodes=mtreeObject.mtfind('Kind','COMMENT');
    cellmarkNodes=mtreeObject.mtfind('Kind','CELLMARK');
    blkcomNodes=mtreeObject.mtfind('Kind','BLKCOM');


    effectiveLinesOfCode=length(unique(codeNodes.lineno));
    commentLinesOfCode=commentNodes.count+cellmarkNodes.count+...
    2*blkcomNodes.count;
    densityOfComments=commentLinesOfCode/totalLinesOfCode;

    metrics.totalLinesOfCode=totalLinesOfCode;
    metrics.effectiveLinesOfCode=effectiveLinesOfCode;
    metrics.commentLinesOfCode=commentLinesOfCode;
    metrics.densityOfComments=densityOfComments;


    metrics.functions=[];
    numFunctions=functionNodes.count;
    functionIndices=functionNodes.indices;
    for idx=1:numFunctions
        thisNode=functionNodes.select(functionIndices(idx));
        thisTree=thisNode.Tree;
        functionName=thisNode.Fname.string;
        noCodeNodes=thisTree.mtfind('Kind',{'COMMENT','CELLMARK','BLKCOM'});
        codeNodes=thisTree.mtfind('~Member',noCodeNodes);
        thisEffectiveLinesOfCode=length(unique(codeNodes.lineno));
        cyclomaticComplexity=get_cyclomaticComplexity(checkCodeResults,...
        functionName);
        metrics.functions(idx).functionName=functionName;
        metrics.functions(idx).effectiveLinesOfCode=thisEffectiveLinesOfCode;
        metrics.functions(idx).cyclomaticComplexity=cyclomaticComplexity;
    end

end

function mtreeObject=get_mtreeObject(typeFlag,argument)
    switch typeFlag
    case 'file'
        mtreeObject=mtree(argument,'-com','-cell','-file');
    case 'code'
        mtreeObject=mtree(argument,'-com','-cell');
    otherwise
        mtreeObject=[];
    end
end

function checkCodeResults=get_checkCodeResults(typeFlag,argument)
    switch typeFlag
    case 'file'
        checkCodeResults=checkcode(argument,'-cyc');
    case 'code'
        checkCodeResults=checkcode('-text',argument,'.m','-cyc');
    otherwise
        checkCodeResults=[];
    end
end

function totalLinesOfCode=get_totalLinesOfCode(typeFlag,argument)
    switch typeFlag
    case 'file'
        codeString=fileread(argument);
    case 'code'
        codeString=argument;
    otherwise
        codeString='';
    end
    lines=strsplit(codeString,'\n','CollapseDelimiters',false);
    totalLinesOfCode=length(lines);
end

function cyclomaticComplexity=get_cyclomaticComplexity(...
    checkCodeResults,functionName)

    cyclomaticComplexity=[];
    pattern=DAStudio.message('CodeAnalyzer:caBuiltins:CABE',['''',functionName,''''],'(\d+)');
    messages={checkCodeResults.message}';
    tokens=regexp(messages,pattern,'tokens');
    for idx=1:length(tokens)
        thisToken=tokens{idx};
        if~isempty(thisToken)
            cyclomaticComplexity=str2double(thisToken{1});
            break;
        end
    end

end

function showedString=createMatlabFileShowedString(fullFileName)
    [~,fileName,fileExtension]=fileparts(fullFileName);
    showedString=[fileName,fileExtension];
end

function commandString=createMatlabFileEditCommandString(fullFileName)
    commandString=fullFileName;
    if ispc
        commandString(commandString=='\')='/';
    end
end

function href=createMatlabFileLink(fullFileName)
    href=sprintf('<a href="matlab: edit(''%s'')">%s</a>',...
    createMatlabFileEditCommandString(fullFileName),...
    createMatlabFileShowedString(fullFileName));
end

function fileDependencies=getFileDependencies(model)
    try

        fileDependencies=dependencies.internal.analyze(which(model),...
        "Include",["MATLABFcn","StateflowMATLABFcn","MATLABFile"],...
        "Traverse","Test",...
        "AnalyzeUnsaved",true);

    catch exception

        if strcmp(exception.identifier,...
            'SimulinkDependencyAnalysis:Engine:UnsavedChanges')
            DAStudio.error('ModelAdvisor:engine:HimlModelNotSavedErrMsg',model);
        else
            rethrow(exception);
        end

    end
end

