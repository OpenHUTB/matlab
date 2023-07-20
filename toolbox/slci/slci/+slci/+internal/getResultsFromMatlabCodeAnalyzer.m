



function[bResultStatus,resultDescription,resultHandles]=...
    getResultsFromMatlabCodeAnalyzer(system,checkParameter)

    bResultStatus=true;
    resultDescription={};
    resultHandles={};

    messageGroup=checkParameter.xlateTagPrefix;

    formatTemplate=checkEMCharts(system,messageGroup);
    if strcmp(formatTemplate.SubResultStatus,'Pass')~=1
        bResultStatus=false;
    end
    resultDescription{end+1}=formatTemplate;
    resultHandles{end+1}=[];

    formatTemplate=checkEMFunctions(system,messageGroup);
    if strcmp(formatTemplate.SubResultStatus,'Pass')~=1
        bResultStatus=false;
    end
    resultDescription{end+1}=formatTemplate;
    resultHandles{end+1}=[];

    formatTemplate=checkMatlabFunctions(system,messageGroup);
    if strcmp(formatTemplate.SubResultStatus,'Pass')~=1
        bResultStatus=false;
    end
    resultDescription{end+1}=formatTemplate;
    resultHandles{end+1}=[];

end

function formatTemplate=checkEMCharts(system,messageGroup)

    status='pass';
    formatTemplate=createFormatTemplate('Emc',messageGroup);

    systemObject=get_param(system,'Object');
    stateflowEmCharts=systemObject.find('-isa','Stateflow.EMChart');

    if isempty(stateflowEmCharts)
        status='none';
    else
        for i=1:length(stateflowEmCharts)
            issueTable=getIssueTable(stateflowEmCharts(i),messageGroup);
            if~isempty(issueTable)
                status='fail';

                stateflowObject=stateflowEmCharts(i);
                formatTemplate.addRow({[...
                ModelAdvisor.Text(Simulink.ID.getSID(stateflowObject)),...
                ModelAdvisor.LineBreak(),...
issueTable...
                ]});

            end
        end
    end

    setSubCheckResult(formatTemplate,messageGroup,'Emc',status)

end

function formatTemplate=checkEMFunctions(system,messageGroup)

    status='pass';
    formatTemplate=createFormatTemplate('Emf',messageGroup);

    systemObject=get_param(system,'Object');
    stateflowEmFunctions=systemObject.find('-isa','Stateflow.EMFunction');

    if isempty(stateflowEmFunctions)
        status='none';
    else
        for i=1:length(stateflowEmFunctions)
            issueTable=getIssueTable(stateflowEmFunctions(i),messageGroup);
            if~isempty(issueTable)
                status='fail';
                stateflowObject=stateflowEmFunctions(i);

                formatTemplate.addRow({[...
                ModelAdvisor.Text(Simulink.ID.getSID(stateflowObject)),...
                ModelAdvisor.LineBreak(),...
issueTable...
                ]});

            end
        end

    end

    setSubCheckResult(formatTemplate,messageGroup,'Emf',status);

end

function formatTemplate=checkMatlabFunctions(system,messageGroup)
    status='pass';
    formatTemplate=createFormatTemplate('Ext',messageGroup);





    if Simulink.harness.isHarnessBD(bdroot(system))
        formatTemplate.setSubResultStatus('Warn');
        warningText=ModelAdvisor.Common.getStrings(...
        'WarningCheckDoesNotSupportHarnessModels');
        actionText=ModelAdvisor.Common.getStrings(...
        'ActionCheckDoesNotSupportHarnessModels');
        formatTemplate.setSubResultStatusText(warningText);
        formatTemplate.setRecAction(actionText);
        return
    end


    calledMatlabFilesMap=getCalledMatlabFiles(system);
    if calledMatlabFilesMap.Count()==0
        status='none';
    else
        keys=calledMatlabFilesMap.keys;
        for i=1:length(keys)
            fileName=keys{i};
            if exist(fileName,'file')

                issueTable=getIssueTable(fileName,messageGroup);
            else
                issueTable=ModelAdvisor.Table(1,1);
                issueTable.setEntry(1,1,ModelAdvisor.Text(...
                DAStudio.message([messageGroup,'Himl0004_FileNotFound'])));
            end
            if~isempty(issueTable)
                status='fail';
                calledBy=calledMatlabFilesMap(fileName);
                usageTable=getUsageTable(calledBy,messageGroup);

                fileNameObject=formatTemplate.formatEntry(fileName);
                [~,theName,theExtension]=fileparts(fileName);
                fileNameObject.Content=[theName,theExtension];
                formatTemplate.UserData.Sid=fileName;
                formatTemplate.UserData.ID='MatlabFcnCodeAnalyzer';

                formatTemplate.addRow({[...
                fileNameObject,...
                usageTable,...
issueTable...
                ]});


            end
        end
    end

    setSubCheckResult(formatTemplate,messageGroup,'Ext',status);

end

function formatTemplate=createFormatTemplate(subCheck,messageGroup)
    formatTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
    formatTemplate.setCheckText(DAStudio.message(...
    [messageGroup,'Himl0004_',subCheck,'_CheckText']));
    formatTemplate.setColTitles({DAStudio.message(...
    [messageGroup,'Himl0004_',subCheck,'_ColTitle'])});
end

function setSubCheckResult(formatTemplate,messageGroup,subCheck,status)
    switch status
    case 'none'
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0004_',subCheck,'_StatusNone']));
    case 'pass'
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0004_',subCheck,'_StatusPass']));
    case 'fail'
        formatTemplate.setSubResultStatus('Warn');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0004_',subCheck,'_StatusFail']));
    end

    if strcmp(status,'fail')
        actionList=ModelAdvisor.List;
        switch subCheck
        case 'Emc'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction2']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction3']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction4']));
        case 'Emf'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction2']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction3']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction4']));
        case 'Ext'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction1']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction2']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction3']));
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0004_RecAction4']));
        end
        formatTemplate.setRecAction(actionList);
    end

end

function issueTable=getIssueTable(stateflowObject,messageGroup)

    issueTable=[];

    matlabCodeAnalyzerResults=getMatlabCodeAnalyzerResults(...
    stateflowObject,messageGroup);

    if~isempty(matlabCodeAnalyzerResults)
        numRows=length(matlabCodeAnalyzerResults);
        issueTable=ModelAdvisor.Table(numRows,4);
        issueTable.setColHeading(1,...
        DAStudio.message([messageGroup,'Himl0004_Line']));
        issueTable.setColHeading(2,...
        DAStudio.message([messageGroup,'Himl0004_Column']));
        issueTable.setColHeading(3,...
        DAStudio.message([messageGroup,'Himl0004_MessageId']));
        issueTable.setColHeading(4,...
        DAStudio.message([messageGroup,'Himl0004_Message']));

        factory=ModelAdvisor.FormatTemplate('TableTemplate');

        switch class(stateflowObject)
        case{'Stateflow.EMChart','Stateflow.EMFunction'}
            sidStart=Simulink.ID.getSID(stateflowObject);
        case 'char'
            sidStart=stateflowObject;
        otherwise
            return;
        end

        for i=1:numRows
            line=matlabCodeAnalyzerResults(i).line;
            column=matlabCodeAnalyzerResults(i).column;
            index=matlabCodeAnalyzerResults(i).index;
            id=matlabCodeAnalyzerResults(i).id;
            message=matlabCodeAnalyzerResults(i).message;

            startIndex=index(1);
            stopIndex=index(2);
            if startIndex>stopIndex
                sid=sprintf('%s:%d-%d',sidStart,startIndex,startIndex);
            else
                sid=sprintf('%s:%d-%d',sidStart,startIndex,stopIndex);
            end
            lineObject=factory.formatEntry(sid);
            lineObject.Content=num2str(line);

            if column(1)>=column(2)
                columnString=sprintf('%d',column(1));
            else
                columnString=sprintf('%d-%d',column(1),column(2));
            end
            columnObject=ModelAdvisor.Text(columnString);
            idObject=ModelAdvisor.Text(id);
            messageObject=ModelAdvisor.Text(message);

            issueTable.setEntry(i,1,lineObject);
            issueTable.setEntry(i,2,columnObject);
            issueTable.setEntry(i,3,idObject);
            issueTable.setEntry(i,4,messageObject);
        end
        issueTable.setCollapsibleMode('all');
        issueTable.setDefaultCollapsibleState('collapsed');
        hiddenContent=DAStudio.message(...
        [messageGroup,'Himl0004_NumIssuesFound'],numRows);
        issueTable.setHiddenContent(hiddenContent);

    end

end

function usageTable=getUsageTable(calledBy,messageGroup)
    usageTable=ModelAdvisor.Table(length(calledBy),1);
    for j=1:length(calledBy)
        block=calledBy{j};
        usageTable.setEntry(j,1,ModelAdvisor.Text(block));
    end
    numCalled=usageTable.NumRow;
    usageTable.setColHeading(1,...
    DAStudio.message([messageGroup,'Himl0005_UsedBy']));
    usageTable.setCollapsibleMode('all');
    usageTable.setDefaultCollapsibleState('collapsed');
    hiddenContent=DAStudio.message(...
    [messageGroup,'Himl0005_UsedByNumBlocks'],num2str(numCalled));
    usageTable.setHiddenContent(hiddenContent);
end

function checkCodeResults=getCheckCodeResults(object)
    checkCodeResults=[];
    switch class(object)
    case 'Stateflow.EMChart'
        checkCodeResults=checkcode('-text',object.Script,'.m','-id','-codegen');
    case 'Stateflow.EMFunction'
        checkCodeResults=checkcode('-text',object.Script,'.m','-id','-codegen');

        checkCodeResults=filterResults(checkCodeResults);
    case 'char'
        checkCodeResults=checkcode(object,'-id');
    otherwise
        return;
    end

end


function newCheckCodeResults=filterResults(oldCheckCodeResults)
    keep=true(size(oldCheckCodeResults));
    for index=1:numel(oldCheckCodeResults)
        switch oldCheckCodeResults(index).id
        case 'COLND',keep(index)=false;
        case 'EMVDF',keep(index)=false;
        case 'NASGU',keep(index)=false;

        case 'NODEF',keep(index)=false;
        otherwise,keep(index)=true;
        end
    end
    newCheckCodeResults=oldCheckCodeResults(keep);
end

function mtreeObject=getMtreeObject(object)
    mtreeObject=[];
    switch class(object)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        mtreeObject=mtree(object.Script,'-com','-cell','-comments');
    case 'char'
        mtreeObject=mtree(object,'-com','-cell','-file','-comments');
    otherwise
        return;
    end
end

function codeString=getCodeString(object)
    codeString=[];
    switch class(object)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        codeString=object.Script;
    case 'char'
        codeString=fileread(object);
    otherwise
        return;
    end
end

function codegenDirectiveFound=hasCodegenDirective(object,mtreeObject)

    codegenDirectiveFound=false;

    switch class(object)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        codegenDirectiveFound=true;
    case 'char'
        commentNodes=mtreeObject.mtfind('Kind','COMMENT');
        for nodeNumber=commentNodes.indices
            thisNode=commentNodes.select(nodeNumber);
            comment=strtrim(thisNode.string);
            if length(comment)>=9
                if strcmp(comment(1:9),'%#codegen')==1
                    codegenDirectiveFound=true;
                    break;
                end
            end
        end
    otherwise
        return;
    end
end

function results=getMatlabCodeAnalyzerResults(object,messageGroup)

    results=struct('line',{},'column',{},'index',{},'id',{},'message',{});

    checkCodeResults=getCheckCodeResults(object);
    mtreeObject=getMtreeObject(object);
    codeString=getCodeString(object);
    codegenDirectiveFound=hasCodegenDirective(object,mtreeObject);

    resultIndex=0;

    if~codegenDirectiveFound
        resultIndex=resultIndex+1;
        results(resultIndex).line=1;
        results(resultIndex).column=[1,1];
        results(resultIndex).index=[1,1];
        results(resultIndex).id='%codegen';
        results(resultIndex).message=DAStudio.message(...
        [messageGroup,'Himl0004_MissingCodegen']);
    end

    for i=1:length(checkCodeResults)
        resultIndex=resultIndex+1;
        line=checkCodeResults(i).line;
        column=checkCodeResults(i).column;
        startIndex=convertLineColumnToIndex(line,column(1),codeString);
        stopIndex=convertLineColumnToIndex(line,column(2),codeString);
        results(resultIndex).line=line;
        results(resultIndex).column=column;
        results(resultIndex).index=[startIndex,stopIndex];
        results(resultIndex).id=checkCodeResults(i).id;
        results(resultIndex).message=checkCodeResults(i).message;
    end

    commentNodes=mtreeObject.mtfind('Kind','COMMENT');
    for nodeNumber=commentNodes.indices
        thisNode=commentNodes.select(nodeNumber);
        comment=strtrim(thisNode.string);
        fullLineDirective=false;
        if length(comment)>=4&&strcmp(comment(1:4),'%#ok')==1
            if length(comment)>=5
                if comment(5)~='<'
                    fullLineDirective=true;
                end
            else
                fullLineDirective=true;
            end
        end
        if fullLineDirective
            line=thisNode.lineno;
            column=[thisNode.charno,thisNode.charno+4];
            index=[thisNode.position,thisNode.endposition];
            message=DAStudio.message(...
            [messageGroup,'Himl0004_UnspecificJustification']);
            resultIndex=resultIndex+1;
            results(resultIndex).line=line;
            results(resultIndex).column=column;
            results(resultIndex).index=index;
            results(resultIndex).id='%#ok';
            results(resultIndex).message=message;
        end
    end

end

function index=convertLineColumnToIndex(line,column,code)
    if line==1
        lineStart=0;
    else
        indexLF=find(code==10);
        lineStart=indexLF(line-1);
    end
    index=lineStart+column;
end

function calledMatlabFilesMap=getCalledMatlabFiles(system)

    calledMatlabFilesMap=containers.Map;

    model=bdroot(system);

    dependencySet=getFileDependencies(model);
    fileDependencies=dependencySet.Edges;

    for i=1:height(fileDependencies)
        fileDependency=fileDependencies(i,:);
        types=strsplit(cell2mat(fileDependency.Type),',');
        fileName=fileDependency.EndNodes{2};




        [~,~,ext]=fileparts(fileName);
        if strcmp(ext,'.m')
            if any(ismember(types,'StateflowMATLABFcn'))
                referenceLocation=fileDependency.UpstreamComponent{1};

                colon=find(referenceLocation==':');
                colon=colon(end);
                block=referenceLocation(1:colon-1);
                id=referenceLocation(colon+1:end);
                ssid=[Simulink.ID.getSID(block),':',id];

                if calledMatlabFilesMap.isKey(fileName)
                    locations=calledMatlabFilesMap(fileName);

                    locations=[locations;ssid];%#ok<AGROW>
                    calledMatlabFilesMap(fileName)=locations;
                else

                    calledMatlabFilesMap(fileName)={ssid};
                end
            end
            if any(ismember(types{1},['MATLABFcn','MATLABFile']))
                referenceLocation=fileDependency.UpstreamComponent{1};
                if calledMatlabFilesMap.isKey(fileName)
                    locations=calledMatlabFilesMap(fileName);
                    locations=[locations;referenceLocation];%#ok<AGROW>
                    calledMatlabFilesMap(fileName)=locations;
                else
                    calledMatlabFilesMap(fileName)={referenceLocation};
                end
            end
        end
    end


end

function dependencySet=getFileDependencies(model)

    try

        dependencySet=dependencies.internal.analyze(which(model),...
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




