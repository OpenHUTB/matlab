



function[bResultStatus,resultDescription,resultHandles]=...
    modelAdvisorCheck_Mfb_GlobalVariables(system,checkParameter)

    bResultStatus=true;
    resultDescription={};
    resultHandles={};

    messageGroup=checkParameter.xlateTagPrefix;


    checkText=DAStudio.message([messageGroup,'Himl0005_CheckText']);
    referenceText=DAStudio.message([messageGroup,'Himl0005_Reference']);
    formatTemplate=ModelAdvisor.FormatTemplate('TableTemplate');
    if~isempty(checkText)
        formatTemplate.setCheckText(checkText);
    end
    if(~isempty(checkText))||(~isempty(referenceText))
        resultDescription{end+1}=formatTemplate;
        resultHandles{end+1}=[];
    end

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

    setSubCheckResult(formatTemplate,messageGroup,'Emc',status);
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


                if endsWith(fileName,'.slx')||endsWith(fileName,'.mdl')
                    continue;
                end
                issueTable=getIssueTable(fileName,messageGroup);
            else
                issueTable=ModelAdvisor.Table(1,1);
                issueTable.setEntry(1,1,ModelAdvisor.Text(...
                DAStudio.message([messageGroup,'Himl0005_FileNotFound'])));
            end
            if~isempty(issueTable)
                status='fail';
                calledBy=calledMatlabFilesMap(fileName);
                usageTable=getUsageTable(calledBy,messageGroup);

                fileNameObject=formatTemplate.formatEntry(fileName);
                [~,theName,theExtension]=fileparts(fileName);
                fileNameObject.Content=[theName,theExtension];

                formatTemplate.addRow({[...
                fileNameObject,...
                ModelAdvisor.LineBreak(),...
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


    if strcmp(subCheck,'Ext')==1
        checkText=...
        DAStudio.message([messageGroup,'Himl0005_',subCheck,'_CheckText']);
        checkNote='<b>Note:</b> this subcheck ...';

        formatTemplate.setCheckText(checkText);
    else
        checkText=...
        DAStudio.message([messageGroup,'Himl0005_',subCheck,'_CheckText']);
        formatTemplate.setCheckText(checkText);
    end



    formatTemplate.setColTitles({...
    DAStudio.message([messageGroup,'Himl0005_',subCheck,'_ColTitle'])});
end

function setSubCheckResult(formatTemplate,messageGroup,subCheck,status)

    switch status
    case 'none'
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0005_',subCheck,'_StatusNone']));
    case 'pass'
        formatTemplate.setSubResultStatus('Pass');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0005_',subCheck,'_StatusPass']));
    case 'fail'
        formatTemplate.setSubResultStatus('Warn');
        formatTemplate.setSubResultStatusText(DAStudio.message(...
        [messageGroup,'Himl0005_',subCheck,'_StatusFail']));
    end

    if strcmp(status,'fail')
        actionList=ModelAdvisor.List;
        switch subCheck
        case 'Emc'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0005_RecAction']));
        case 'Emf'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0005_RecAction']));
        case 'Ext'
            actionList.addItem(...
            DAStudio.message([messageGroup,'Himl0005_RecAction']));
        end
        formatTemplate.setRecAction(actionList);
    end

end

function calledMatlabFilesMap=getCalledMatlabFiles(system)

    calledMatlabFilesMap=containers.Map;

    model=bdroot(system);
    dependencySet=getFileDependencies(model);
    fileDependencies=dependencySet.Edges;

    for i=1:height(fileDependencies)
        fileDependency=fileDependencies(i,:);
        if~contains(fileDependency.UpstreamComponent,system)
            continue
        end
        types=strsplit(cell2mat(fileDependency.Type),',');
        if any(ismember(types,'StateflowMATLABFcn'))
            fileName=fileDependency.EndNodes{2};
            referenceLocation=char(fileDependency.UpstreamComponent);

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
        if any(ismember(types,'MATLABFcn'))
            fileName=fileDependency.EndNodes{2};
            referenceLocation=char(fileDependency.UpstreamComponent);
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

function dependencySet=getFileDependencies(model)

    try

        dependencySet=dependencies.internal.analyze(which(model),...
        "Include",["StateflowMATLABFcn","MATLABFcn"],...
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

function issueTable=getIssueTable(stateflowObject,messageGroup)

    issueTable=[];

    globalVariables=findGlobalVariables(stateflowObject);

    if~isempty(globalVariables)

        numRows=size(globalVariables,1);
        issueTable=ModelAdvisor.Table(numRows,3);
        issueTable.setColHeading(1,...
        DAStudio.message([messageGroup,'Himl0005_Line']));
        issueTable.setColHeading(2,...
        DAStudio.message([messageGroup,'Himl0005_Column']));
        issueTable.setColHeading(3,...
        DAStudio.message([messageGroup,'Himl0005_Variables']));
        issueTable.setCollapsibleMode('all');
        issueTable.setDefaultCollapsibleState('collapsed');
        hiddenContent=DAStudio.message(...
        [messageGroup,'Himl0005_NumIssuesFound'],num2str(numRows));
        issueTable.setHiddenContent(hiddenContent);

        factory=ModelAdvisor.FormatTemplate('TableTemplate');

        switch class(stateflowObject)
        case{'Stateflow.EMChart','Stateflow.EMFunction'}
            sidStart=Simulink.ID.getSID(stateflowObject);
        case 'char'
            sidStart=stateflowObject;
        otherwise
            return;
        end

        for row=1:numRows
            line=globalVariables{row,1};
            column=globalVariables{row,2};
            startIndex=globalVariables{row,3};
            stopIndex=globalVariables{row,4};
            variables=globalVariables{row,5};
            sid=sprintf('%s:%d-%d',sidStart,startIndex,stopIndex);
            lineString=factory.formatEntry(sid);
            lineString.Content=num2str(line);
            columnString=num2str(column);
            variableString=cellStrings2String(variables);
            issueTable.setEntry(row,1,lineString);
            issueTable.setEntry(row,2,columnString);
            issueTable.setEntry(row,3,variableString);
        end

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

function results=findGlobalVariables(object)

    results=cell(0,3);

    switch class(object)
    case{'Stateflow.EMChart','Stateflow.EMFunction'}
        mtreeObject=mtree(object.Script,'-com','-cell');
    case 'char'
        mtreeObject=mtree(object,'-com','-cell','-file');
    otherwise
        return;
    end

    globalNodes=mtreeObject.mtfind('Kind','GLOBAL');

    for nodeNumber=globalNodes.indices
        thisNode=globalNodes.select(nodeNumber);
        startPosition=thisNode.position;
        endPosition=thisNode.endposition;
        line=thisNode.lineno;
        column=thisNode.charno;
        argNode=thisNode.Arg;
        globalVariables=[];
        globalVariables{1}=argNode.string;
        while~isempty(argNode.Next)
            argNode=argNode.Next;
            globalVariables{end+1}=argNode.string;%#ok<AGROW>
        end
        results{end+1,1}=line;%#ok<AGROW>
        results{end,2}=column;
        results{end,3}=startPosition;
        results{end,4}=endPosition;
        results{end,5}=globalVariables;
    end

end

function string=cellStrings2String(cellStrings)
    string=cellStrings{1};
    for i=2:length(cellStrings)
        string=[string,', ',cellStrings{i}];%#ok<AGROW>
    end
end

