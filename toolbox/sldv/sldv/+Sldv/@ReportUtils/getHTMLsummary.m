function str=getHTMLsummary(sldvData,existResults,model,isHighlighted,...
    forInformer,justifiedObjs)




    if nargin<5
        forInformer=false;
    end

    if nargin<6
        justifiedObjs=[];
    end

    dataFile=existResults.DataFile;

    if isempty(sldvData)
        sldvData=Sldv.ReportUtils.loadAndCheckSldvData(dataFile);
    end

    [activeObjectives,justifiedObjs,isXIL,canApplyFilter]=Sldv.ReportUtils.getActiveAndJustifiedObjectives(sldvData,justifiedObjs);

    possibleResultActions=struct('Filter',canApplyFilter,...
    'Harness',false,...
    'Report',true,...
    'Highlight',isHighlighted,...
    'SimForCov',false,...
    'DispUnsatisfiable',false,...
    'ExportToSlTest',false,...
    'SaveToSpreadsheet',false);


    possibleResultActions=Sldv.ReportUtils.updatePossibleResultActions(possibleResultActions,sldvData,model,isHighlighted,activeObjectives,canApplyFilter);

    quickDeadLogicSuggestion=htmlQuickDeadLogicSuggestion(sldvData,model,forInformer);

    firstSentence=htmlFirstSentence(sldvData,forInformer);

    objSummary=htmlObjSummaryTable(sldvData,forInformer,'Objectives',...
    activeObjectives,justifiedObjs);



    resultActions=htmlResultActions(existResults,model,possibleResultActions,forInformer,isXIL);
    resultsFileHtml=htmlResultsFile(existResults,forInformer);

    str=[firstSentence,quickDeadLogicSuggestion,objSummary,resultActions,resultsFileHtml];
end

function quickDeadLogicSuggestion=htmlQuickDeadLogicSuggestion(sldvData,model,forInformer)
    if~Sldv.utils.isQuickDeadLogic(sldvData.AnalysisInformation.Options)||...
        Sldv.utils.isSldvAnalysisRunning(model)||forInformer

        quickDeadLogicSuggestion='';
        return;
    end

    activeLogicDialogStr=getString(message('Sldv:dialog:sldvDesignErrPanelActiveLogic'));
    quickDeadLogicSuggestion=getString(message('Sldv:ReportUtils:prepareObjectives:QuickDeadLogicIncompleteCheckWarning',...
    activeLogicDialogStr));
    quickDeadLogicSuggestion=['<p>',quickDeadLogicSuggestion,'<p>','</p>'];
end

function outStr=htmlResultActions(existResults,model,possibleResults,forInformer,isXIL)
    if nargin<5
        isXIL=false;
    end

    dataFile=existResults.DataFile;

    resultsStr=getString(message('Sldv:Informer:Results'));
    if forInformer
        outStr=sprintf('<p><b>%s</b><ul>\n',resultsStr);
    else
        outStr=sprintf('%s\n<ul>\n',resultsStr);
    end

    if possibleResults.Filter
        outStr=[outStr,resultMethod(getString(message('Sldv:Informer:OpenFilterViewer')),'filter')];
    end

    if possibleResults.Highlight
        outStr=[outStr,resultMethod(getString(message('Sldv:Informer:HighlightAnalysisResultsOnModel')),'highlight')];
    end

    if possibleResults.Harness

        outStr=[outStr,resultMethod(getString(message('Sldv:Informer:ViewTestsSDI')),'viewinsdi')];
    end

    if~isempty(existResults.Report)&&~Sldv.utils.isSldvAnalysisRunning(model)
        outStr=[outStr,'<li>',getString(message('Sldv:Informer:GenerateDetailedAnalysisReport')),':'];
        outStr=[outStr,'  (',htmlReportLink(getString(message('Sldv:Informer:HtmlReport')),existResults.Report,model),')'];
    elseif possibleResults.Report
        outStr=[outStr,'<li>',getString(message('Sldv:Informer:GenerateDetailedAnalysisReport')),':'];
        outStr=[outStr,'  (',getResultMethodUrl(getString(message('Sldv:Informer:HtmlReport')),'report'),')'];
    end

    if license('test','MATLAB_Report_Gen')&&isfield(existResults,'PDFReport')
        if~isempty(existResults.PDFReport)
            outStr=[outStr,' (',htmlPDFReportLink(getString(message('Sldv:Informer:PdfReport')),existResults.PDFReport,model),')'];
        elseif possibleResults.Report
            outStr=[outStr,' (',getResultMethodUrl(getString(message('Sldv:Informer:PdfReport')),'pdfreport'),')'];
        end
    end

    outStr=[outStr,sprintf('</li>\n')];


    if strcmp(get_param(model,'isHarness'),'off')
        if~isempty(existResults.HarnessModel)
            outStr=[outStr,'<li>',htmlModelLink(getString(message('Sldv:Informer:OpenHarnessModel')),existResults.HarnessModel),sprintf('</li>\n')];
        elseif possibleResults.Harness&&strcmp(get_param(get_param(model,'Handle'),'isHarness'),'off')
            outStr=[outStr,resultMethod(getString(message('Sldv:Informer:CreateHarnessModel')),'harness')];
        end
    end


    if possibleResults.SaveToSpreadsheet
        outStr=[outStr,resultMethod(getString(message('Sldv:Informer:SaveToSpreadsheet')),'SaveToSpreadsheet')];
    end


    if isfield(existResults,'SLTestFile')&&~isempty(existResults.SLTestFile)
        outStr=[outStr,'<li>',htmlSlTestFileLink(getString(message('Sldv:Informer:ViewSLTestFile')),existResults.SLTestFile),sprintf('</li>\n')];
    elseif possibleResults.ExportToSlTest
        outStr=[outStr,resultMethod(getString(message('Sldv:Informer:ExportTestcasesInSLTest')),'export_to_sltest')];
    end

    if possibleResults.SimForCov
        msgId='Sldv:Informer:SimulateTestsAndProduce';
        if isXIL
            msgId=[msgId,'SIL'];
        end
        outStr=[outStr,resultMethod(getString(message(msgId)),'covReport')];
    end



    function opStr=getResultMethodUrl(label,method)
        url=Sldv.ReportUtils.htmlResultsURL(method,dataFile,model);
        opStr=sprintf('%s',link(url,label));
    end

    function opStr=resultMethod(label,method)
        url=Sldv.ReportUtils.htmlResultsURL(method,dataFile,model);
        opStr=sprintf('<li>%s</li>\n',link(url,label));
    end

    outStr=[outStr,sprintf('\n</ul>\n')];
end

function outStr=htmlDirLink(path)
    url=Sldv.ReportUtils.htmlResultsURL('opendir',path,'');
    outStr=link(url,path);
end
function outStr=htmlModelLink(label,path)
    url=Sldv.ReportUtils.htmlResultsURL('openmodel',path,'');
    outStr=link(url,label);
end

function outStr=htmlDataLink(label,path)
    url=Sldv.ReportUtils.htmlResultsURL('loaddata',path,'');
    outStr=link(url,label);
end

function outStr=htmlReportLink(label,path,model)
    url=Sldv.ReportUtils.htmlResultsURL('openreport',path,model);
    outStr=link(url,label);
end

function outStr=htmlSlTestFileLink(label,path)
    url=Sldv.ReportUtils.htmlResultsURL('view_sltest_result',path,'');
    outStr=link(url,label);
end

function outStr=htmlPDFReportLink(label,path,model)
    url=Sldv.ReportUtils.htmlResultsURL('openpdfreport',path,model);
    outStr=link(url,label);
end

function outStr=htmlResultsFile(existResults,forInformer)
    if forInformer
        outStr='';
        return;
    end

    dataFile=existResults.DataFile;

    if~isempty(dataFile)
        [dataDir,file,ext]=fileparts(dataFile);
        dataName=[file,ext];
        if ispc
            resolvedDataDir=htmlDirLink(dataDir);
        else
            resolvedDataDir=dataDir;
        end
        saveDataStr=getString(message('Sldv:Informer:DataSavedInInFolder',htmlDataLink(dataName,dataFile),resolvedDataDir));
        outStr=sprintf('%s<br><br>\n',saveDataStr);
    else
        outStr='';
    end
end

function outStr=htmlFirstSentence(sldvData,forInformer)
    mode=sldvData.AnalysisInformation.Options.Mode;
    if strcmp(sldvData.AnalysisInformation.Options.RequirementsTableAnalysis,'off')
        activityStr=sldvprivate('util_translate_analysismode',mode);
    else
        activityStr=getString(message('Sldv:KeyWords:RequirementsTableMode'));
    end
    status=sldvData.AnalysisInformation.Status;
    statusStr=sldvprivate('util_translate_analysisstatus',status,'Lower');

    if forInformer


        if strcmpi('In progress',status)&&...
            ~slavteng('feature','IncrementalHighlighting')
            elapsedTimeSecs=sldvData.AnalysisInformation.ElapsedTime;
            timestr=sec2hms(elapsedTimeSecs);
            statusStr=getString(message('Sldv:Informer:InProgressTimeElapsedIs',activityStr,timestr));
            outStr=sprintf('<b>%s</b>',statusStr);
        else
            outStr=sprintf('<b>%s %s</b>',activityStr,statusStr);
        end
    else
        if Sldv.DataUtils.isXilSldvData(sldvData)
            if Sldv.utils.Options.isTestgenTargetForModelRefCode(sldvData.AnalysisInformation.Options)
                modeKey='TestGenerationModeForGeneratedModelRefCode';
            else
                modeKey='TestGenerationModeForGeneratedCode';
            end
            activityStr=sldvprivate('util_translate_analysismode',modeKey);
        end
        outStr=sprintf('%s %s<br>',activityStr,statusStr);
    end
end


function timestr=sec2hms(secs)
    hour=floor(secs/3600);
    min=floor(rem(secs,3600)/60);
    sec=rem(secs,60);

    if hour>0
        timestr=sprintf('%d:%02d:%02d',hour,min,sec);
    else
        timestr=sprintf('%d:%02d',min,sec);
    end
end

function objStr=htmlObjSummaryTable(sldvData,forInformer,usefield,activeObjectives,justifiedObjectives)
    if nargin<3
        usefield='Objectives';
    end

    if nargin<4
        activeObjectives=sldvData.(usefield);
    end

    if nargin<5
        justifiedObjectives=[];
    end

    DesiredOrder=Sldv.utils.getDesiredObjectiveStatusReportingOrder();

    allStatus={};


    if~isempty(activeObjectives)
        activeObjectives=getFilteredObjectives(activeObjectives);
    end

    numQuickDeadLogicNotFoundToBeDead=0;
    numUndecided=0;

    for i=1:length(activeObjectives)
        o=activeObjectives(i);
        if~strcmpi(o.status,'n/a')
            allStatus{end+1}=o.status;%#ok<AGROW>
            if strcmpi(o.status,'Undecided')
                numUndecided=numUndecided+1;
            end
        elseif slfeature('SLDVCombinedDLRTE')&&...
            any(strcmp(o.type,Sldv.utils.getDeadLogicObjectiveTypes))
            allStatus{end+1}=o.status;%#ok<AGROW>
            numQuickDeadLogicNotFoundToBeDead=numQuickDeadLogicNotFoundToBeDead+1;
        end
    end
    for i=1:length(justifiedObjectives)
        allStatus{end+1}='Justified';%#ok<AGROW>
    end






    if slfeature('SLDVCombinedDLRTE')
        objTotal=numel(activeObjectives)+numel(justifiedObjectives);
    elseif Sldv.utils.isQuickDeadLogic(sldvData.AnalysisInformation.Options)



        objTotal=sum(strcmp({activeObjectives.type},'Decision'))+...
        sum(strcmp({activeObjectives.type},'Condition'))+...
        sum(strcmp({activeObjectives.type},'S-Function Decision'))+...
        sum(strcmp({activeObjectives.type},'S-Function Condition'));
    else
        objTotal=numel(allStatus);
    end






    modelName=sldvData.ModelInformation.Name;
    isSldvAnalysisRunning=Sldv.utils.isSldvAnalysisRunning(modelName);



    if isSldvAnalysisRunning

        allStatus(strcmpi(allStatus,'Undecided')|strcmpi(allStatus,'n/a'))={'In progress'};



        DesiredOrder(strcmpi(DesiredOrder,'Undecided')|strcmpi(DesiredOrder,'n/a'))={'In progress'};
    else

        allStatus=allStatus(strcmp(allStatus,'n/a')==0);

    end








    allStatusOrdered=intersect(DesiredOrder,allStatus,'stable');






    allStatusKeys=cell(numel(allStatusOrdered),1);

    for idx=1:numel(allStatusOrdered)
        allStatusKeys{idx}=Sldv.InspectorWorkflow.InspectorUtils.getMsgSuffix(allStatusOrdered{idx});
    end

    uniqueStatusKeys=unique(allStatusKeys,'stable');


    [uniqueStatus,~,idxUniqueStatus]=unique(allStatus);

    keyCountMap=containers.Map('KeyType','char','ValueType','double');

    for idx=1:length(uniqueStatus)
        status=uniqueStatus{idx};
        statusKey=Sldv.InspectorWorkflow.InspectorUtils.getMsgSuffix(status);

        if~isKey(keyCountMap,statusKey)
            keyCountMap(statusKey)=0;
        end
        keyCountMap(statusKey)=keyCountMap(statusKey)+sum(idxUniqueStatus==idx);
    end


    statusCounts.current=0;
    statusCounts.total=objTotal;
    statusCounts.undecided=numUndecided;
    statusCounts.undead=numQuickDeadLogicNotFoundToBeDead;

    statusStringList={};
    rowIdx=1;
    for idx=1:numel(uniqueStatusKeys)
        currStatusKey=uniqueStatusKeys{idx};
        statusCounts.current=keyCountMap(currStatusKey);
        currStatusString=getStringForStatus(currStatusKey,statusCounts);

        if strcmp(currStatusString,'')
            continue;
        end

        statusStringList{rowIdx}=currStatusString;%#ok<AGROW>
        rowIdx=rowIdx+1;
    end



    options=sldvData.AnalysisInformation.Options;
    if Sldv.utils.isQuickDeadLogic(options)
        if(forInformer&&numel(uniqueStatus)==0&&~isSldvAnalysisRunning)
            label=getString(message('Sldv:Informer:NoDeadLogicFound'));
            statusStringList{1}=label;
        end
    end

    allStatus=statusStringList';
    objStr=table(allStatus);
    if~forInformer
        objStr=sprintf('%s<br/>\n<br/>',strjoin(allStatus,'<br/>\n'));
    end
end


function statusString=getStringForStatus(currStatusKey,statusCounts)
    statusString='';


    switch currStatusKey
    case 'InProgress'
        numerator=statusCounts.undecided+statusCounts.undead;
    case 'Undecided'
        numerator=statusCounts.undecided;
    case 'na'
        return
    otherwise
        numerator=statusCounts.current;
    end

    if numerator==1
        msgId=['Sldv:Informer:OneObj',currStatusKey];
    else
        msgId=['Sldv:Informer:MultObj',currStatusKey];
    end

    statusString=getString(message(msgId,numerator,statusCounts.total));
end

function objectives=getFilteredObjectives(objectives)


    objectives(strcmp({objectives.type},'Non masking'))=[];

    objectives(strcmp({objectives.type},'Range'))=[];
end


function str=link(url,label)
    str=sprintf('<A HREF=%s>%s</A>',url,label);
end

function str=table(cellStr,attrStr)

    if nargin<2
        attrStr='border=0';
    end

    str=sprintf('<table %s>\n',attrStr);

    rowCnt=size(cellStr,1);
    for idx=1:rowCnt
        str=[str,tablerow(cellStr{idx,:})];%#ok<AGROW>
    end
    str=[str,sprintf('</table>\n')];
end

function str=tablerow(varargin)
    str='<tr>';
    for idx=1:nargin
        str=sprintf('%s<td>%s</td>',str,varargin{idx});
    end
    str=sprintf('%s</tr>\n',str);
end



