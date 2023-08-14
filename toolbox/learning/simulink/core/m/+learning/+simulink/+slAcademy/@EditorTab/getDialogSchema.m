function dlgstruct=getDialogSchema(this,~)


    items=getItems(this);
    dlgstruct=getDlgStruct(this,items);

end

function items=getItems(this)

    items=generateItems(this);

end


function items=generateItems(this)

    signalContainer=generatePlotContainer(this);

    checkItems=cell(1,numel(this.matlabChecks)*2);
    itemNo=1;

    taskNum=LearningApplication.getCurrentTask();
    if taskNum>0
        interactionAssessments=learning.simulink.Application.getInstance().getInteractionAssessments();
        currentAssessments=interactionAssessments{taskNum};
        if~isstruct(currentAssessments)&&~isempty(this.blkHandle)
            this.matlabPassStatus(1)=str2double(get_param(this.blkHandle,'pass'));
        end
    end

    for idx=1:numel(this.matlabChecks)
        [reqName,reqStatus]=generateStatusRow(this.matlabChecks,this.matlabPassStatus,idx);
        checkItems{itemNo}=reqName;
        checkItems{itemNo+1}=reqStatus;
        itemNo=itemNo+2;
    end

    if numel(this.matlabChecks)==0
        if strcmp(this.tabType,'blank')||strcmp(this.tabType,'optional')||strcmp(this.tabType,'quiz')
            pass=-1;
        else
            pass=str2double(get_param(this.blkHandle,'pass'));
        end
        [reqName,reqStatus]=generateStatusRow(...
        {message('learning:simulink:resources:AssessmentPaneSignalRequirement').getString()},...
        pass,1);
        checkItems{1}=reqName;
        checkItems{2}=reqStatus;
    end

    reqsContainer=generateRequirementsContainer(this,checkItems);

    defaultText=generateDefaultText(this);

    spacer.Type='panel';
    spacer.Enabled=0;
    spacer.RowSpan=[4,4];
    spacer.ColSpan=[1,1];

    if strcmp(this.tabType,'blank')||strcmp(this.tabType,'optional')||strcmp(this.tabType,'quiz')
        signalContainer.Visible=0;
        reqsContainer.Visible=0;
    else
        defaultText.Visible=0;
        if strcmp(this.tabType,'soln-noimg')
            signalContainer.Visible=0;
        end
    end

    items={signalContainer,reqsContainer,defaultText,spacer};


end

function reqsContainer=generateRequirementsContainer(this,reqItems)

    reqsContainer.Name=message('learning:simulink:resources:RequirementsWidgetText').getString();
    reqsContainer.Type='group';
    if numel(this.matlabChecks)==0
        rows=1;
    else
        rows=numel(this.matlabChecks);
    end
    reqsContainer.LayoutGrid=[rows,1];
    reqsContainer.RowSpan=[2,2];
    reqsContainer.ColSpan=[1,1];
    reqsContainer.Items=reqItems;
    reqsContainer.BackgroundColor=[240,248,255];
end

function[reqName,reqStatus]=generateStatusRow(checks,status,reqNumber)


    reqName.Type='text';
    reqName.WordWrap=true;
    reqName.ColSpan=[2,30];
    reqName.Alignment=0;
    reqName.FontPointSize=10;

    reqName.Name=checks{reqNumber};
    reqName.Tag=['Custom Requirement ',num2str(reqNumber)];
    reqName.RowSpan=[reqNumber,reqNumber];


    imgMap=containers.Map({0,1,-1},{'fail.png','pass.png','ns.png'});

    srcPath=learning.simulink.SimulinkAppInteractions.getSLTrainingPath();
    basePath=fullfile(srcPath,'Resources');

    reqStatus.Type='image';
    reqStatus.ColSpan=[1,1];
    reqStatus.Alignment=3;

    reqStatus.Tag=['Status ',num2str(reqNumber)];
    reqStatus.RowSpan=[reqNumber,reqNumber];
    reqStatus.FilePath=fullfile(basePath,imgMap(status(reqNumber)));

end

function plotContainer=generatePlotContainer(this)

    plotContainer.Type='group';
    plotContainer.LayoutGrid=[2,1];
    plotContainer.RowSpan=[1,1];
    plotContainer.Alignment=0;

    plotContainer.ColSpan=[1,1];
    plotContainer.BackgroundColor=[240,248,255];

    plotContainer.Name=message('learning:simulink:resources:SignalWidgetName',this.graderNumber).getString();
    link=generatePopoutLink(this);
    tabImg=generatePlotRow(this);
    plotContainer.Items={tabImg,link};

end

function defaultText=generateDefaultText(this)

    if strcmp(this.tabType,'optional')
        defaultText.Name=['   ',message('learning:simulink:resources:AssessmentPaneOptionalText').getString()];
    elseif strcmp(this.tabType,'quiz')
        defaultText.Name=['   ',message('learning:simulink:resources:AssessmentPaneQuizText').getString()];
    else
        defaultText.Name=['   ',message('learning:simulink:resources:AssessmentPaneBlankText').getString()];
    end
    defaultText.Type='text';
    defaultText.Tag='Default text';
    defaultText.RowSpan=[3,3];
    defaultText.ColSpan=[1,1];
    defaultText.Alignment=6;
    defaultText.PreferredSize=[360,50];
    defaultText.FontPointSize=9;
end

function tabImg=generatePlotRow(~)


    tabImg.Type='webbrowser';
    tabImg.Tag='SignalImage';

    connectorPath=learning.simulink.Application.getInstance().getConnectorPath();
    assessmentURL=connector.getUrl([connectorPath,'learning_content/',...
    'application/signal.html?time=',num2str(now)]);
    tabImg.Url=assessmentURL;
    tabImg.DisableContextMenu=true;
    tabImg.MinimumSize=[-1,325];
    tabImg.MaximumSize=[375,-1];
    tabImg.DialogRefresh=true;
    tabImg.RowSpan=[1,1];
    tabImg.Alignment=0;

end

function popoutHyperlink=generatePopoutLink(~)
    popoutHyperlink.Name=message('learning:simulink:resources:AssessmentPaneInspectSignal').getString();
    popoutHyperlink.FontPointSize=10;
    popoutHyperlink.Type='hyperlink';
    popoutHyperlink.Tag='openPlotWindow';
    popoutHyperlink.ObjectMethod='openPlotWindow';
    popoutHyperlink.ToolTip=message('learning:simulink:resources:AssessmentPaneInspectTooltip').getString();
    popoutHyperlink.Alignment=3;
    popoutHyperlink.RowSpan=[2,2];
    popoutHyperlink.ColSpan=[1,1];
end

function dlgstruct=getDlgStruct(this,items)


    switch this.tabType
    case{'blank','soln','soln-noimg','optional','quiz'}
        dlgstruct.DialogTitle='';
        dlgstruct.DialogTag=learning.simulink.slAcademy.EditorTab.ASSESS_PANE_DOCKED_TAG;
    end
    numrows=numel(items);

    dlgstruct.LayoutGrid=[numrows,1];
    dlgstruct.RowStretch=zeros(1,numrows);
    dlgstruct.RowStretch(end)=1;
    colstretch=zeros(1,1);
    colstretch(1)=1;
    dlgstruct.ColStretch=colstretch;

    dlgstruct.StandaloneButtonSet={''};
    dlgstruct.EmbeddedButtonSet={''};
    dlgstruct.IsScrollable=true;
    dlgstruct.MinimalApply=true;
    dlgstruct.DialogRefresh=true;
    dlgstruct.Items=items;

    dlgstruct.ExplicitShow=true;
end
