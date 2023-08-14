function dlgstruct=getDialogSchema(this,~)




    dlgstruct.Type='panel';
    dlgstruct.LayoutGrid=[8,3];
    dlgstruct.RowStretch=[0,0,0,0,0,1,1,0];
    dlgstruct.ColStretch=[1,0,0];
    dlgstruct.Source=this;
    criterionGroup=getCriterionGroup(this);
    criterionGroup.RowSpan=[1,6];
    criterionGroup.ColSpan=[1,3];
    msdlg=this.Model.modelSlicer.dlg;
    isBusy=false;
    if isa(msdlg,'DAStudio.Dialog')...
        &&isa(msdlg.getSource,'SEUdd.ModelSlicerDlg')
        isBusy=msdlg.getSource.Busy;
    end
    if this.Model.isInEditableHighlight||this.Model.modelSlicer.hasError
        isBusy=true;
    end
    dlgstruct.Enabled=~isBusy;

    statusText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:Ready')),...
    'Enabled',true,'RowSpan',[8,8],'ColSpan',[1,3],...
    'Visible',true,'Source',this,...
    'WordWrap',true,...
    'MinimumSize',[330,10],...
    'Tag','DialogStatusText');

    hasRepGenLic=license('test','SIMULINK_Report_Gen');

    [sliceGenEnabled,toolTip]=allowGenerateSlice(this);

    generateButton=struct('Type','pushbutton',...
    'Tag','generateSliceTag',...
    'Name',getString(message('Sldv:ModelSlicer:gui:GenerateSlice')),...
    'RowSpan',[7,7],'ColSpan',[3,3]);
    generateButton.Enabled=sliceGenEnabled;
    generateButton.ToolTip=toolTip;
    generateButton.ObjectMethod='generate';
    generateButton.MethodArgs={'%dialog'};
    generateButton.ArgDataTypes={'handle'};
    generateButton.Source=this;
    generateButton.Visible=~this.lockedForInspect;

    if hasRepGenLic&&isReportGeneratorInstalled()
        [webReportEnabled,toolTip]=allowGenerateWebView(this);
        generateWVButton=struct('Type','pushbutton',...
        'Tag','generateWebViewTag',...
        'Name',getString(message('Sldv:ModelSlicer:gui:ExportToWeb')),...
        'RowSpan',[7,7],'ColSpan',[2,2]);
        generateWVButton.Enabled=webReportEnabled;
        generateWVButton.ToolTip=toolTip;
        generateWVButton.ObjectMethod='generateWebView';
        generateWVButton.MethodArgs={'%dialog'};
        generateWVButton.ArgDataTypes={'handle'};
        generateWVButton.Source=this;
        dlgstruct.Items={criterionGroup,statusText,generateWVButton};
    else
        dlgstruct.Items={criterionGroup,statusText};
    end
    dlgstruct.Items{end+1}=generateButton;

    function yesno=isReportGeneratorInstalled()
        yesno=exist('slwebview_slicer','file');
    end
end

function[isEnabled,toolTip]=allowGenerateSlice(this)
    isEnabled=false;
    mdlH=this.Model.modelSlicer.modelH;
    if~this.Model.modelSlicer.compiled
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipNeedCompile'));
    elseif~strcmp(this.Model.direction,'Back')
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipNeedBack'));
    elseif~isempty(this.Model.constraints.keys)||~isempty(this.Model.covConstraints.keys)
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipHaveConstraints'));
    elseif isempty(this.Model.getUserStarts)
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipNoSeed'));
    elseif this.Model.modelSlicer.isHarness
        toolTip=getString(message('Sldv:ModelSlicer:gui:HarnessSliceIsNotSupported'));
    elseif this.Model.modelSlicer.inSteppingMode()
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipUnsupStepping'));
    elseif locMdlHasObservers()
        toolTip=getString(message(...
        'Sldv:ModelSlicer:ModelSlicer:UnsupportedObserverContentSliceGeneration',...
        getfullname(mdlH)));
    elseif Simulink.internal.isArchitectureModel(mdlH)
        toolTip=getString(message(...
        'Sldv:ModelSlicer:ModelSlicer:UnsupportedArchModelSliceGeneration',...
        getfullname(mdlH)));
    else
        isEnabled=true;
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenSliceTooltipEnabled'));
    end

    function yesno=locMdlHasObservers()
        yesno=slfeature('NewSlicerBackend')>0&&...
        ~isempty(this.Model.modelSlicer.obsMdlToRefBlk);
    end
end

function[isEnabled,toolTip]=allowGenerateWebView(this)
    isEnabled=false;

    isDirty=false;
    msdlg=this.Model.modelSlicer.dlg;
    if~isempty(msdlg)

        scfg=msdlg.getSource.Model;
        for scIdx=scfg.allDisplayed
            if scfg.sliceCriteria(scIdx).dirty...
                ||isempty(scfg.sliceCriteria(scIdx).allNonVirtualBlocks)
                isDirty=true;
            end
        end
    end
    if isempty(this.Model.getUserStarts)
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenWebViewTooltipNoSeed'));
    elseif this.Model.isInEditableHighlight
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenWebViewTooltipInEditableMode'));
    elseif isDirty
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenWebViewTooltipHasDirtyConfig'));
    else
        isEnabled=true;
        toolTip=getString(message('Sldv:ModelSlicer:gui:GenWebViewTooltipEnabled'));
    end
end

function criterionGroup=getCriterionGroup(this)
    criterionGroup=struct('Type','group','LayoutGrid',[8,5],...
    'RowStretch',[0,0,0,0,0,1,0,0],'ColStretch',[0,0,0,1,1]);
    criterionGroup.Flat=true;
    criterionGroup.Tag='CriteriaGroup';

    nameEditbox=struct('Type','edit',...
    'Name',getString(message('Sldv:ModelSlicer:gui:SliceListName')),...
    'RowSpan',[1,1],'ColSpan',[1,4],'Mode',true,...
    'Value',this.Model.name,...
    'Graphical',true,...
    'Tag','sliceName',...
    'Enabled',~this.lockName);
    nameEditbox.ObjectMethod='updateSliceName';
    nameEditbox.MethodArgs={'%dialog'};
    nameEditbox.ArgDataTypes={'handle'};


    color=this.Model.colorValue*255;
    colorButton=struct('Type','pushbutton','Name',' ','BackgroundColor',...
    color,'RowSpan',[1,1],'ColSpan',[5,5],'MaximumSize',[20,20],...
    'Tag','colorButton');
    colorButton.ObjectMethod='updateColor';
    colorButton.MethodArgs={'%dialog'};
    colorButton.ArgDataTypes={'handle'};
    colorButton.Visible=~this.lockedForInspect;

    description=struct('Type','editarea',...
    'Name',getString(message('Sldv:ModelSlicer:gui:ConfigurationCriterionDescription')),...
    'MaximumSize',[10000,40],...
    'RowSpan',[2,2],'ColSpan',[1,5],'Mode',true,'WordWrap',true,...
    'Tag','criteriaDescription','ObjectMethod','updateDescription',...
    'Source',this,'Graphical',true);
    description.Value=this.Model.description;
    description.MethodArgs={'%dialog'};
    description.ArgDataTypes={'handle'};

    tableText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:SignalPropagation')),...
    'RowSpan',[3,3],'ColSpan',[1,1]);

    directionCombo=struct('Type','combobox','Mode',true,'Value',1,...
    'RowSpan',[3,3],'ColSpan',[3,3],'Name','',...
    'Tag','directionCombo');
    directionCombo.Entries={...
    getString(message('Sldv:ModelSlicer:gui:UpStreamCombobox'))...
    ,getString(message('Sldv:ModelSlicer:gui:DownStreamCombobox'))...
    ,getString(message('Sldv:ModelSlicer:gui:BidirectionalCombobox'))...
    };
    directionCombo.ObjectMethod='updateDirection';
    directionCombo.MethodArgs={'%dialog'};
    directionCombo.ArgDataTypes={'handle'};
    directionCombo.Alignment=1;

    directionCombo.Enabled=~this.lockedForInspect;

    switch lower(this.Model.direction)
    case 'back'
        directionCombo.Value=0;
        iconpath=fullfile(matlabroot,'toolbox','sldv','slicer',...
        'resources','upstream.png');
    case 'forward'
        directionCombo.Value=1;
        iconpath=fullfile(matlabroot,'toolbox','sldv','slicer',...
        'resources','downstream.png');
    otherwise
        directionCombo.Value=2;
        iconpath=fullfile(matlabroot,'toolbox','sldv','slicer',...
        'resources','updownstream.png');
    end

    directionImg=struct('Type','image','FilePath',iconpath,...
    'RowSpan',[3,3],'ColSpan',[2,2]...
    );
    directionImg.Alignment=1;


    thisSeeds=this.Model.toStruct;
    thisSeeds.isInEditableHighlight=this.Model.isInEditableHighlight;

    if isempty(this.htmlStrCache)...
        ||isempty(this.prevSeeds)...
        ||~isequal(thisSeeds,this.prevSeeds)...
        ||(isfield(thisSeeds,'CovConstraints')&&~isempty(thisSeeds.CovConstraints))...
        ||(isfield(thisSeeds,'DeadLogicSys')&&~isempty(thisSeeds.DeadLogicSys))
        htmlStr=getJSTable(this.Model,this.lockedForInspect);
    else
        htmlStr=this.htmlStrCache;
    end
    webTable=struct('Type','webbrowser','RowSpan',[5,6],...
    'ColSpan',[1,5],...
    'HTML',htmlStr,...
    'Tag','CriteriaHTMLDisp',...
    'WebKit',true);
    criterionGroup.Items={nameEditbox,colorButton,...
    description,tableText,directionCombo,...
    webTable,directionImg};

    inStepperMode=this.Model.modelSlicer.inSteppingMode();

    if slavteng('feature','EnhancedCoverageSlicer')
        coverageGroup=getCoverageGroupEnhanced(this);
    else
        coverageGroup=getCoverageGroup(this);
    end

    coverageGroup.RowSpan=[7,7];
    coverageGroup.ColSpan=[1,5];
    criterionGroup.Items{end+1}=coverageGroup;

    if~inStepperMode
        if slavteng('feature','DeadlogicForSlice')
            deadLogicGroup=getDeadLogicGroup(this);
            deadLogicGroup.RowSpan=[8,8];
            deadLogicGroup.ColSpan=[1,5];
        end
        criterionGroup.Items{end+1}=deadLogicGroup;
    end




    this.prevSeeds=thisSeeds;
    this.htmlStrCache=htmlStr;
end

function dlgstruct=getDeadLogicGroup(this)
    dlEnabled=~isempty(this.Model.deadLogicData);
    panelStr=getString(message('Sldv:ModelSlicer:gui:DeadLogicTitle'));
    if dlEnabled
        panelStr=[panelStr,' ',getString(message('Sldv:ModelSlicer:gui:Enabled'))];
    end
    dlgstruct=struct('Type','togglepanel',...
    'LayoutGrid',[2,2],...
    'Name',panelStr,...
    'Tag','DeadLogicGroup','Flat',true);
    dlgstruct.Expand=this.Model.useDeadLogic;
    if~dlEnabled
        sldvgroup=getCreateSldvDataGroup(this);
    else
        sldvgroup=getSldvInfoGroup(this);
    end
    dlgstruct.Items={sldvgroup};
end

function dlgstruct=getCoverageGroupEnhanced(this)
    covEnabled=~isempty(this.Model.cvd);
    panelStr=getString(message('Sldv:ModelSlicer:gui:SimulationTimeWindow'));
    if covEnabled
        panelStr=[panelStr,' ',getString(message('Sldv:ModelSlicer:gui:Enabled'))];
    end
    dlgstruct=struct('Type','togglepanel',...
    'LayoutGrid',[2,2],...
    'Name',panelStr,...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:UseSimulationTimeWindow')),...
    'Tag','CovGroup','Flat',true);
    dlgstruct.Expand=this.Model.useCvd;

    if~covEnabled
        covgroup=getCreateCovDataGroup(this);
    else
        covgroup=getRefineCovDataGroup(this);
    end
    dlgstruct.Items={covgroup};
end

function group=getRefineCovDataGroup(this)

    inStepperMode=this.Model.modelSlicer.inSteppingMode();

    group=struct('Type','panel',...
    'LayoutGrid',[4,3],...
    'RowStretch',[0,0,0,0],'ColStretch',[0,0,0],...
    'RowSpan',[2,2],...
    'ColSpan',[1,2],...
    'Name','','Tag','RefineCovDataGroup');
    simDataText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:SimDataText')),...
    'Visible',~inStepperMode,...
    'Tag','SimDataTxt',...
    'RowSpan',[1,1],...
    'ColSpan',[1,2]);

    clearDataButton=struct('Type','pushbutton',...
    'Visible',~inStepperMode,...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:ClearToolTip')),...
    'Name',getString(message('Sldv:ModelSlicer:gui:ClearText')),...
    'RowSpan',[2,3],...
    'ColSpan',[1,1],...
    'Tag','ClearCovButton',...
    'Enabled',~this.lockClearSimData);

    clearDataButton.ObjectMethod='clearCov';
    clearDataButton.MethodArgs={'%dialog'};
    clearDataButton.ArgDataTypes={'handle'};

    enableTimeWindowChange=~isempty(this.Model.cvd.covStreamMap)&&~inStepperMode;
    sdiDisabled=ModelSlicer.isSlicerSdiOpen()&&isThisUsingSdi(this.Model.modelSlicer);

    cvFileName=this.Model.cvFileName;
    cvFileParts=strsplit(cvFileName,filesep);

    covFileText=struct('Type','text',...
    'Name',cvFileParts{end},...
    'Visible',~inStepperMode,...
    'ToolTip',cvFileName,...
    'Alignment',7,...
    'Tag','covFlTxt',...
    'RowSpan',[2,2],...
    'ColSpan',[3,3]);


    [actualStartTime,actualStopTime]=this.Model.cvd.getStartStopTime(this.Model.modelSlicer);
    startTime=this.Model.cvd.streamStartTime;
    stopTime=this.Model.cvd.streamStopTime;
    intervalText=getString(message('Sldv:ModelSlicer:gui:IntervalTimeText',...
    num2str(startTime),num2str(stopTime)));

    covFileTSText=struct('Type','text',...
    'Name',intervalText,...
    'Visible',~inStepperMode,...
    'FontPointSize',5,...
    'Tag','covFlTSTxt',...
    'Alignment',7,...
    'RowSpan',[3,3],...
    'ColSpan',[3,3]);

    TimeWindowPanel=struct('Type','group',...
    'Name',getString(message('Sldv:ModelSlicer:gui:TimeWindowText')),...
    'LayoutGrid',[5,5],...
    'RowSpan',[5,5],...
    'ColSpan',[1,2],...
    'Tag','TimeWindowPanel','Flat',true);

    FromText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:FromText')),...
    'Visible',~isempty(this.Model.cvd),...
    'Tag','FromTTxt',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);

    ToText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:ToText')),...
    'Visible',~isempty(this.Model.cvd),...
    'Tag','ToTxt',...
    'RowSpan',[2,2],...
    'ColSpan',[3,3]);

    startTimeEdit=struct('Type','edit',...
    'Tag','SimTstartTime',...
    'ObjectMethod','setWindowChanged',...
    'Enabled',enableTimeWindowChange&&~sdiDisabled,...
    'MinimumSize',[10,10],...
    'RowSpan',[2,2],...
    'ColSpan',[2,2]);

    startTimeEdit.MethodArgs={'%dialog'};
    startTimeEdit.ArgDataTypes={'handle'};


    stopTimeEdit=struct('Type','edit',...
    'Tag','SimTstopTime',...
    'ObjectMethod','setWindowChanged',...
    'Enabled',enableTimeWindowChange&&~sdiDisabled,...
    'MinimumSize',[10,10],...
    'RowSpan',[2,2],...
    'ColSpan',[4,4]);

    stopTimeEdit.MethodArgs={'%dialog'};
    stopTimeEdit.ArgDataTypes={'handle'};


    cvd=this.Model.cvd;
    intervals=cvd.getConstraintTimeIntervals();
    if~isempty(intervals)



        numIntervals=size(intervals,1);

        numDisplayed=min(numIntervals,2);

        text=cell(1,numDisplayed);
        for i=1:numDisplayed
            text{i}=getString(message('Sldv:ModelSlicer:gui:IntervalTimeText',...
            num2str(intervals(i,1)),num2str(intervals(i,2))));
        end


        if numDisplayed<numIntervals
            text{end+1}='... ';
        end


        twText=strjoin(text,', ');


        twText=[twText,' : ',getString(message('Sldv:ModelSlicer:gui:NumIntervalText',num2str(numIntervals)))];
        simTimeText=getString(message('Sldv:ModelSlicer:gui:ConstrTimeText',...
        twText));
    else
        simTimeText=getString(message('Sldv:ModelSlicer:gui:ActualTimeText',...
        num2str(actualStartTime),num2str(actualStopTime)));

    end

    actTimeText=struct('Type','text',...
    'Name',simTimeText,...
    'WordWrap',true,...
    'Tag','actStartTime',...
    'FontPointSize',7,...
    'Alignment',5,...
    'RowSpan',[3,3],...
    'ColSpan',[1,4]);



    msdlg=this.Model.modelSlicer.dlg;
    if isa(msdlg,'DAStudio.Dialog')&&isa(msdlg.getSource,'SEUdd.ModelSlicerDlg')
        if isempty(msdlg.getWidgetValue('SimTstartTime'))
            startTimeEdit.Value=actualStartTime;
        end
        if isempty(msdlg.getWidgetValue('SimTstopTime'))
            stopTimeEdit.Value=actualStopTime;
        end
    end


    RefineButton=struct('Type','pushbutton',...
    'Visible',true,...
    'Name',getString(message('Sldv:ModelSlicer:gui:RefineBt')),...
    'Enabled',enableTimeWindowChange&&this.windowChanged&&~sdiDisabled,...
    'RowSpan',[2,2],...
    'ColSpan',[5,5],...
    'Tag','RefineButton');

    RefineButton.ObjectMethod='refineTimeWindow';
    RefineButton.MethodArgs={'%dialog'};
    RefineButton.ArgDataTypes={'handle'};

    sdiButton=struct('Type','pushbutton',...
    'Visible',true,...
    'Name',getString(message('Sldv:ModelSlicer:gui:InspectSignals')),...
    'Enabled',enableTimeWindowChange&&~sdiDisabled,...
    'RowSpan',[3,3],...
    'ColSpan',[5,5],...
    'Tag','SdiButton');

    sdiButton.ObjectMethod='launchSdi';
    sdiButton.MethodArgs={'%dialog'};
    sdiButton.ArgDataTypes={'handle'};

    TimeWindowPanel.Items={FromText,ToText,startTimeEdit,stopTimeEdit,...
    RefineButton,sdiButton,actTimeText};

    TimeWindowPanel.RowSpan=[5,6];
    TimeWindowPanel.ColSpan=[1,4];


    group.Items={TimeWindowPanel,simDataText,clearDataButton,covFileText,covFileTSText};

    if inStepperMode
        portLabelChbox.Type='checkbox';
        portLabelChbox.RowSpan=[2,2];
        portLabelChbox.ColSpan=[1,2];
        portLabelChbox.Name=getString(message('Sldv:ModelSlicer:gui:TogglePortLabels'));
        portLabelChbox.Tag='PortLabelChBox';
        portLabelChbox.ObjectMethod='togglePortLabels';
        portLabelChbox.MethodArgs={'%dialog'};
        portLabelChbox.ArgDataTypes={'handle'};
        portLabelChbox.Value=this.Model.showLabels;
        group.Items{end+1}=portLabelChbox;

        ctrlDepChbox.Type='checkbox';
        ctrlDepChbox.RowSpan=[3,3];
        ctrlDepChbox.ColSpan=[1,2];
        ctrlDepChbox.Name=getString(message('Sldv:ModelSlicer:gui:ToggleCtrlDep'));
        ctrlDepChbox.Tag='CtrlDepChBox';
        ctrlDepChbox.ObjectMethod='toggleCtrlDep';
        ctrlDepChbox.MethodArgs={'%dialog'};
        ctrlDepChbox.ArgDataTypes={'handle'};
        ctrlDepChbox.Value=this.Model.showCtrlDep;
        group.Items{end+1}=ctrlDepChbox;
    end
end

function group=getCreateSldvDataGroup(this)
    inStepperMode=this.Model.modelSlicer.inSteppingMode();
    group=struct('Type','panel',...
    'LayoutGrid',[1,2],...
    'RowStretch',0,'ColStretch',[0,0],...
    'RowSpan',[2,2],...
    'ColSpan',[1,2],...
    'Name','','Tag','SldvGroupNew');

    GetDataLink=struct('Type','hyperlink',...
    'Name',getString(message('Sldv:ModelSlicer:gui:GetDeadLogic')),...
    'Visible',isempty(this.Model.deadLogicData),...
    'Enabled',~inStepperMode,...
    'Tag','GetDeadLogicLink',...
    'RowSpan',[1,1],...
    'ColSpan',[1,2]);
    GetDataLink.ObjectMethod='openSldvDlg';
    GetDataLink.MethodArgs={'%dialog'};
    GetDataLink.ArgDataTypes={'handle'};
    group.Items={GetDataLink};
end

function group=getSldvInfoGroup(this)
    group=struct('Type','panel',...
    'LayoutGrid',[2,2],...
    'RowStretch',[0,0],'ColStretch',[0,0],...
    'RowSpan',[2,2],...
    'ColSpan',[1,2],...
    'Name','','Tag','SldvInfoGroup');

    clearDataButton=struct('Type','pushbutton',...
    'Visible',~isempty(this.Model.deadLogicData),...
    'Name',getString(message('Sldv:ModelSlicer:gui:ClearText')),...
    'RowSpan',[1,1],...
    'ColSpan',[2,2],...
    'Tag','ClearSldvButton');

    clearDataButton.ObjectMethod='clearDeadLogic';
    clearDataButton.MethodArgs={'%dialog'};
    clearDataButton.ArgDataTypes={'handle'};

    sldvFileName=this.Model.sldvFileName;
    sldvFileParts=strsplit(sldvFileName,filesep);

    sldvFileText=struct('Type','text',...
    'Name',sldvFileParts{end},...
    'Visible',~isempty(this.Model.deadLogicData),...
    'ToolTip',sldvFileName,...
    'Alignment',7,...
    'Tag','sldvFlTxt',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);

    group.Items={clearDataButton,sldvFileText};
end


function group=getCreateCovDataGroup(this)
    inStepperMode=this.Model.modelSlicer.inSteppingMode();
    group=struct('Type','panel',...
    'LayoutGrid',[2,2],...
    'RowStretch',[0,0],'ColStretch',[0,0],...
    'RowSpan',[2,2],...
    'ColSpan',[1,2],...
    'Name','','Tag','CovGroupNew');
    RunText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:RunSimText')),...
    'Visible',isempty(this.Model.cvd),...
    'Tag','RunTxt',...
    'RowSpan',[1,1],...
    'ColSpan',[1,1]);

    CovText=struct('Type','text',...
    'Name',getString(message('Sldv:ModelSlicer:gui:UseSimDataText')),...
    'Visible',isempty(this.Model.cvd),...
    'Tag','FromTTxt',...
    'RowSpan',[2,2],...
    'ColSpan',[1,1]);
    runSimBtn=struct('Type','pushbutton',...
    'Visible',isempty(this.Model.cvd),...
    'Enabled',~inStepperMode,...
    'FilePath',fullfile(matlabroot,'toolbox','shared','dastudio',...
    'resources','glue','Toolbars','16px','Play_16.png'),...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:RunSimulationSpecifySimulation')),...
    'Tag','RunSimButton',...
    'Alignment',7,...
    'RowSpan',[1,1],...
    'ColSpan',[2,2]);
    runSimBtn.ObjectMethod='openRunSimDlg';
    runSimBtn.MethodArgs={'%dialog'};
    runSimBtn.ArgDataTypes={'handle'};

    coverageBrowse=struct('Type','pushbutton',...
    'Enabled',~inStepperMode,...
    'Visible',isempty(this.Model.cvd),...
    'FilePath',fullfile(matlabroot,'toolbox','shared','dastudio',...
    'resources','glue','Toolbars','16px','Open_16.png'),...
    'RowSpan',[2,2],...
    'ColSpan',[2,2],...
    'Tag','CovFileButton',...
    'Alignment',7,...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:BrowseCoverageDataSpecify')));
    coverageBrowse.ObjectMethod='loadCvFile';
    coverageBrowse.MethodArgs={'%dialog'};
    coverageBrowse.ArgDataTypes={'handle'};
    coverageBrowse.Source=this;

    group.Items={RunText,CovText,runSimBtn,coverageBrowse};

end

function dlgstruct=getCoverageGroup(this)

    dlgstruct=struct('Type','group',...
    'LayoutGrid',[3,4],...
    'RowStretch',[0,0,0],'ColStretch',[1,1,1,0],...
    'Name','','Tag','CovGroup','Flat',true);

    if isempty(this.Model.cvd)&&~isempty(this.Model.cvd)
        if isa(this.Model.cvd.data,'cv.cvdatagroup')
            rawCvd=this.Model.cvd.data.get(this.Model.modelSlicer.model);
        else
            rawCvd=this.Model.cvd.data;
        end
        [startTime,stopTime]=this.Model.cvd.getStartStopTime(this.Model.modelSlicer);
        if startTime==0&&stopTime==0
            StartText=getString(message('Sldv:ModelSlicer:gui:StartTimeWithData',0));
            StopText=getString(message('Sldv:ModelSlicer:gui:StopTimeWithData','-'));
        else
            intervalStartTime=num2str(startTime,'%15.15g');
            intervalStopTime=num2str(stopTime,'%15.15g');
            StartText=getString(message('Sldv:ModelSlicer:gui:StartTimeWithData',intervalStartTime));
            StopText=getString(message('Sldv:ModelSlicer:gui:StopTimeWithData',intervalStopTime));
        end
        ToolTip=getString(message('Sldv:ModelSlicer:gui:RecordedOn',this.Model.cvFileName,...
        rawCvd.startTime));
    elseif isempty(this.Model.cvd)&&~isempty(this.Model.cvFileName)
        StartText=getString(message('Sldv:ModelSlicer:gui:StartTimeNotActive'));
        StopText=getString(message('Sldv:ModelSlicer:gui:StopTimeNotActive'));
        ToolTip=this.Model.cvFileName;
    else
        StartText=getString(message('Sldv:ModelSlicer:gui:StartTimeNodata'));
        StopText=getString(message('Sldv:ModelSlicer:gui:StopTimeNodata'));
        ToolTip='';
    end

    simTimeStartText=struct('Type','text',...
    'Name',StartText,...
    'Visible',isempty(this.Model.cvd),...
    'ToolTip',ToolTip,...
    'Tag','SimTstartTxt',...
    'RowSpan',[2,2],...
    'ColSpan',[1,2]);
    simTimeStopText=struct('Type','text',...
    'Name',StopText,...
    'Visible',isempty(this.Model.cvd),...
    'ToolTip',ToolTip,...
    'Tag','SimTstopTxt',...
    'RowSpan',[3,3],...
    'ColSpan',[1,2]);

    runSimBtn=struct('Type','pushbutton',...
    'Visible',isempty(this.Model.cvd),...
    'FilePath',fullfile(matlabroot,'toolbox','shared','dastudio',...
    'resources','glue','Toolbars','16px','Play_16.png'),...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:RunSimulationSpecifySimulation')),...
    'Tag','RunSimButton',...
    'RowSpan',[2,2],...
    'ColSpan',[4,4]);
    runSimBtn.ObjectMethod='openRunSimDlg';
    runSimBtn.MethodArgs={'%dialog'};
    runSimBtn.ArgDataTypes={'handle'};

    coverageBrowse=struct('Type','pushbutton',...
    'Visible',isempty(this.Model.cvd),...
    'FilePath',fullfile(matlabroot,'toolbox','shared','dastudio',...
    'resources','open.png'),...
    'RowSpan',[3,3],...
    'ColSpan',[4,4],...
    'Tag','CovFileButton',...
    'ToolTip',getString(message('Sldv:ModelSlicer:gui:BrowseCoverageDataSpecify')));
    coverageBrowse.ObjectMethod='loadCvFile';
    coverageBrowse.MethodArgs={'%dialog'};
    coverageBrowse.ArgDataTypes={'handle'};
    coverageBrowse.Source=this;

    dlgstruct.Items={...
    simDataStat,simTimeStartText,simTimeStopText,runSimBtn,...
    coverageBrowse};
end

function col=getPathColumn(elem)
    if~isfield(elem,'Type')||any(strcmp(elem.Type,{'block','subsystem','model'}))
        col=get_param(elem.Handle,'Name');
    elseif strcmp(elem.Type,'state')
        col=elem.Handle.Name;
    elseif strcmp(elem.Type,'transition')
        col=elem.Handle.LabelString;
    else

        bh=get(elem.Handle,'ParentHandle');
        col=sprintf('%s:%d',get_param(bh,'Name'),get(elem.Handle,'PortNumber'));
    end
    if isfield(elem,'BusElementPath')&&~isempty(elem.BusElementPath)
        col=convertStringsToChars...
        (strcat(col,"~",elem.BusElementPath));
    end
end


function[string]=getJSTable(sc,lockedForInspect)

    document=Advisor.Document;

    LineBreak='<span class="LineBreak"><br clear="all"></span>';
    modelName=get_param(sc.modelSlicer.modelH,'Name');

    css_ms=Advisor.Element('style','type','text/css');
    css_ms.setContent(fileread(fullfile(matlabroot,'toolbox','sldv','slicer',...
    'resources','modelslicer.css')));


    document.addHeadItem(css_ms);


    BGcolor=Advisor.Element('style','type','text/css');
    if~sc.isInEditableHighlight
        BGcolor.setContent('<!-- body { background-color: #ffffff; } -->');
    else
        BGcolor.setContent('<!-- body { background-color: #f8f8f8; } -->');
    end
    document.addItem(BGcolor);


    JSFct=fileread(fullfile(matlabroot,'toolbox','simulink','simulink',...
    'modeladvisor','private','AdvisorCollapsible.js'));

    JS=Advisor.Element('script','type','text/javascript');
    JS.setContent(JSFct);
    document.addItem(JS);


    mjsscr=fileread(fullfile(matlabroot,'toolbox','sldv','slicer',...
    'resources','modelslicer.js'));
    mjs=Advisor.Element('script','type','text/javascript');
    mjs.setContent(mjsscr);

    document.addItem(mjs);

    if~isempty(sc.deadLogicData)
        [subsystbl0,tts0]=generateTable(modelName,sc,'deadLogic');
        subsystbl0.setCollapsibleMode('all');
        document.addItem(tts0);
        document.addItem(subsystbl0);
        document.addItem(LineBreak);
    end
    if~isempty(sc.sliceSubSystemH)
        [subsystbl,tts]=generateTable(modelName,sc,'subsystem');
        subsystbl.setCollapsibleMode('none');
        document.addItem(tts);
        document.addItem(subsystbl);
        document.addItem(LineBreak);
    end

    [tbl1,tt1]=generateTable(modelName,sc,'seeds',lockedForInspect);
    if~isempty(sc.getUserStarts)
        tbl1.setCollapsibleMode('all')
    end
    document.addItem(tt1);
    document.addItem(tbl1);

    if~isempty(sc.getUserExclusions)
        document.addItem(LineBreak);
        [tbl2,tt2]=generateTable(modelName,sc,'terminals',lockedForInspect);
        tbl2.setCollapsibleMode('all')
        document.addItem(tt2);
        document.addItem(tbl2);
    end

    if~isempty(sc.constraints)
        document.addItem(LineBreak);
        [tbl3,tt3]=generateTable(modelName,sc,'constraints');
        tbl3.setCollapsibleMode('all');
        document.addItem(tt3);
        document.addItem(tbl3);
    end

    if~isempty(sc.covConstraints)
        document.addItem(LineBreak);
        [tbl4,tt4]=generateTable(modelName,sc,'covConstraints');
        tbl4.setCollapsibleMode('all');
        document.addItem(tt4);
        document.addItem(tbl4);
    end

    string=document.emitHTML;
end

function[table,tableTitle]=generateTable(modelName,sc,seedType,lockedForInspect)
    if nargin<4
        lockedForInspect=false;
    end
    sigIcon=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAMAAA'...
    ,'AoLQ9TAAAAMFBMVEUAAAD////5+fns7Ozm5ubZ2dnMzMzGxsa/v7+5ubmmpqb///8A'...
    ,'AAAAAAAAAAAAAACw/vk8AAAAB3RJTUUH0gkEEhwBn4L4dwAAAEtJREFUeJydj0EKgD'...
    ,'AQA4PJxtr+/7/KSsX2oNA5LXPIsGgTWBQA+IgJImxfRy1OApQUqEco4T2KEmMF1p94'...
    ,'VVLQu3slxUZpqHz9cgJxrwgh5Yt4MQAAAABJRU5ErkJggg=='];
    blockIcon=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAY'...
    ,'AAAAf8/9hAAAACXBIWXMAAAsTAAALEwEAmpwYAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZ'...
    ,'SBJbWFnZVJlYWR5ccllPAAAAOlJREFUeNrkktsNgkAQRUdiAZZgC4QGpAL9JOHLEqx'...
    ,'AOyB2YAtWoAVAtBnej3XuZocsqyT+Gic5gWFn7jxYop+3he0EQaC+ScqybMxbuodpm'...
    ,'k78pmkoz/OROI4n5x5XfTDruWpKqQmm0zHeY64MRDZu8jAM1LYtdV1Hfd9rjCF+pwV'...
    ,'4nhM/QyZxk+u61gIChIwh/sgiydsOUEUqQwBgD/CtDsRW2AE6uDEHfJFlFUVBZVlqR'...
    ,'ER2YOLP3P0eO9gyPjv3TwJVVWmc6iHHX/Rv5BffPkEyRkACZkbrVmW5B8/ZexBFEf2'...
    ,'ZvQQYAFEntRavCJdRAAAAAElFTkSuQmCC'];
    whitepng=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYA'...
    ,'AACNMs+9AAAACXBIWXMAAA7EAAAOxAGVKw4bAAAAB3RJTUUH3goUEQMj5YXkYAAAAF'...
    ,'FJREFUGNPFzkEKgDAMBdFJXCno/c8leBUxJW1cKSgtducsw4MfiQhqeXI0J3ScANAa'...
    ,'ssMQ22/UhL6tDPPyuElr+p3S2SfMRB/U5JSIP368OgHD6Byp8GXkUgAAAABJRU5Erk'...
    ,'Jggg=='];
    stateIcon=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0'...
    ,'NAAABWUlEQVQ4je3TS0sCURjGcT9Luz5DQTfLy3GcFM1pk1CLHJzpggpjZUEXiD5CLUL'...
    ,'atygjSLo6m0FBDTKKJgVRFyEEWSRjPC1cHWZhzqqgB37bP+/iHJPpzywSicuEbLWs1g2w7'...
    ,'PaPeDw7miQdpHSx2PJ+IhzaRVrJolxSUauUOqqWi0grWYRDu1hbiR9TQY97XVPkK6Cpdi2X'...
    ,'keGb2NSoIMvEUH2+Bj4yXWu+KnCPr4IKOomEmnoEvCUNYZkoHWTsIVTu9/BVjxvCkjAdJBY'...
    ,'eanoejeKCIYyVp4M2sx93FyN4yQ8YQkan6KB1eBL5015UlR5D7GaODlqG/CicD6Ke7+taLd'...
    ,'Ovv9AxNqOlDjk0Hjxdy5354CbT9DtcEvnE4iyP26SA90cRrVJnn08iCpcCAn4ekhA40X2/6J'...
    ,'x4w7kEzesMwu1oc9raXETP6wyCcwlaJCjKutj/fte+AY/wjEyLQ+HQAAAAAElFTkSuQmCC'];

    transIcon=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABQAAAAUCAYAAACNiR0NAAABh0',...
    'lEQVQ4ja2TkdbrQBRGBwf7AIFAtDBYDAQG8xCFQiFYiOQBBgKFQKFYCASCg8FCZGAgECgOBIr7U',...
    'u9avXL7/81Za3SfPd85R4i163Q6IaWkqipWAUopUUohpVwHWFUVUkq22y3OuXWgQggxDANFUWCt',...
    'XQ/qnGO/32OMWQ8qhBBlWVIUBSEEHo8HaZp+1+D5fHK5XDgej0RRhJSS+/3+vXWSJMRxTBzHZFn',...
    'GsizM84z3Hucc3nvmeWZZlv83K8sSKSWbzYYkSYiiiL7vsdbSdR1t29J1HdZaxnEkhPDZD+q6Rmv',...
'NbrfjcDhgjEFrjVKKPM8xxtD3PeM4fmYqhBDzPGOtpaoqsizjdrsxTRNN06CUwhiDtZZ5nj8Deu/'...
    ,'pug6tNdfrlRDC39c0DXme03Ud3vvPgM452rZFKcU0TW/AYRhQStG27eeX9jLM85ymad6Ar4x/ZPj',...
    'K0BiDUorz+cwwDNR1TZqmP89wWRbGcaTv+7cpa61/N2UhhAghMI7j93v4r+mvL+W39QcgWZwbiQM',...
    '2uQAAAABJRU5ErkJggg=='];

    modelIcon=['data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAABq0lEQ',...
    'VQ4jZ3S30tTcRjH8dHFkOnQA+v4A3VsjMZxU8FuIlAjF0Xtq4gsLzpNEXVq2Rh4wIngQoeGlHY1Rh',...
    'cqIhEEQ6EIvVigIOHFWoQ/SJwTvOqPeHdjEOTJkx947r7P64Hv85hMZ6mb2s55nm91mS4bZWwDZWwD9',...
    '+h62qV9bP5vwBVJ0fspz43pNK5ICmf4/YLjyYrdMGAPLRPZ/kn/51NuvfmCM/wOe2iZyt6FCSmQLNZt',...
    'FEIghKAimEBdP6Z19YCbKxmciU3KhhapCCZwqK/4/U4IwbmQHJil8W2W60s7OCbXKFVfIwdmkR++nJA',...
    'CM8V/DjwXkPwxqmc+cDU4j+SPIfljqZL7U3/9gS5g9WlYfRpFLVq66I6muwVdwNIczhU2PbvwDnSBf2Wp',...
    'VkavDAFJr41v8QGy4ypfn/rIqLXstFWT9NqMAXMeiZP5QU5edJEfvUsuVM9BZxVzHskYEK+xko/eIz9ym',...
    '+OhBg4fu9htsxGvsRoDooqFXJ+Xox6FH4+c7LXLZH0FRBWLMWDYbWa/o5y99lK+Pygh22Im02hi2G02BnR',...
    'fu4Je/QKu09iq4A9ejgAAAABJRU5ErkJggg=='];


    switch seedType

    case 'seeds'
        id='1';
        if lockedForInspect

            title=getString(message('Sldv:DebugUsingSlicer:ValidateEMCDCStartingPoint'));
        else
            title=getString(message('Sldv:ModelSlicer:gui:StartingPoints'));
        end
        elem=sc.getUserStarts();
    case 'terminals'
        id='2';
        if lockedForInspect

            title=getString(message('Sldv:DebugUsingSlicer:ValidateEMCDCExclusionPoint'));
        else
            title=getString(message('Sldv:ModelSlicer:gui:ExclusionPoints'));
        end
        elem=sc.getUserExclusions;
    case 'subsystem'
        id='3';
        title=getString(message('Sldv:ModelSlicer:gui:SliceSubsystem'));
        elem.Handle=sc.sliceSubSystemH;
        elem.Type='subsystem';
    case 'constraints'
        id='4';
        title=getString(message('Sldv:ModelSlicer:gui:Constraints'));
        c=sc.constraints.keys;
        for n=1:length(c)
            e.Handle=Simulink.ID.getHandle(c{n});
            e.Type='block';
            e.PortStruct=sc.constraints(c{n});
            elem(n)=e;%#ok<AGROW>
        end
    case 'covConstraints'
        id='5';
        title=getString(message('Sldv:ModelSlicer:gui:CovConstraints'));
        c=sc.covConstraints.keys;
        for n=1:length(c)
            e.Handle=Simulink.ID.getHandle(c{n});
            if isnumeric(e.Handle)&&ishandle(e.Handle)
                e.Type='block';
            elseif isa(e.Handle,'Stateflow.State')||...
                isa(e.Handle,'Stateflow.AtomicSubchart')
                e.Type='state';
            elseif isa(e.Handle,'Stateflow.Transition')
                e.Type='transition';
            end
            e.Value=sc.covConstraints(c{n});
            elem(n)=e;%#ok<AGROW>
        end
    case 'deadLogic'
        id='6';
        title=getString(message('Sldv:ModelSlicer:gui:RefinedComponents'));
        c=sc.deadLogicData.getAllRefinedSys;
        elem=struct('Type',[],'Handle',[]);
        for n=1:length(c)
            e.Handle=Simulink.ID.getHandle(c{n});
            if Simulink.SubsystemType.isBlockDiagram(e.Handle)
                e.Type='model';
            else
                e.Type='subsystem';
            end
            elem(n)=e;
        end
    end

    if isempty(elem)
        table=Advisor.Table(1,1);
        table.setAttribute('class','SlicerTable');
        tbl1=Advisor.Text(getString(message('Sldv:ModelSlicer:gui:NoSeedItems')));
        tbl1.setItalic(true);
        table.setEntry(1,1,tbl1);
        tableTitle=Advisor.Text(title);
        tableTitle.SpanClass='TableTitle';
        tableTitle=Advisor.Text;
        tableTitle.SpanClass='TableTitle';
        allAllHyperlink='';
        if strcmp(sc.direction,'Back')||strcmp(sc.direction,'Either')
            addAllOutports=Advisor.Text(getString(message('Sldv:ModelSlicer:gui:AddAllOutputs')));
            addAllOutports.Hyperlink=sprintf('matlab:SlicerConfiguration.addDefaultStartingPoint(''%s'',''Outport'');'...
            ,modelName);
            addAllOutports.SpanClass='LinkInTitle';
            allAllHyperlink=[allAllHyperlink,addAllOutports.emitHTML];
        end
        if strcmp(sc.direction,'Forward')||strcmp(sc.direction,'Either')
            addAllInports=Advisor.Text(getString(message('Sldv:ModelSlicer:gui:AddAllInputs')));
            addAllInports.Hyperlink=sprintf('matlab:SlicerConfiguration.addDefaultStartingPoint(''%s'',''Inport'');'...
            ,modelName);
            addAllInports.SpanClass='LinkInTitle';
            allAllHyperlink=[allAllHyperlink,addAllInports.emitHTML];
        end
        tableTitle.Content=[title,allAllHyperlink];
        return;
    end

    if~strcmp(seedType,'subsystem')

        clearAll=Advisor.Text(getString(message('Sldv:ModelSlicer:gui:ClearAll')));
        clearAll.Hyperlink=sprintf('matlab:SlicerConfiguration.clearAllSeeds(''%s'',''%s'');'...
        ,modelName,seedType);
        clearAll.SpanClass='LinkInTitle';
        titleText=Advisor.Text(title);
        tableTitle=Advisor.Text;
        if lockedForInspect

            tableTitle.Content=[titleText.emitHTML];
        else
            tableTitle.Content=[titleText.emitHTML,clearAll.emitHTML];
        end
    else
        tableTitle=Advisor.Text(title);
    end
    tableTitle.SpanClass='TableTitle';
    table=Advisor.Table(length(elem),1);
    table.setAttribute('class','SlicerTable');

    vidx=1;
    valid=true;
    for idx=1:length(elem)
        try
            if isfield(elem(idx),'Type')
                type=elem(idx).Type;
            else
                type='block';
            end
            if any(strcmp(type,{'block','subsystem'}))
                fPath=getfullname(elem(idx).Handle);
                iconPath=blockIcon;
            elseif strcmp(type,'state')
                fPath=[elem(idx).Handle.Path,'/',elem(idx).Handle.Name];
                iconPath=stateIcon;
            elseif strcmp(type,'transition')
                fPath=elem(idx).Handle.LabelString;
                iconPath=transIcon;
            elseif strcmp(type,'model')
                fPath=getfullname(elem(idx).Handle);
                iconPath=modelIcon;
            else
                lh=get(elem(idx).Handle,'Line');
                if~ishandle(lh)


                    valid=false;
                    handleType=getString(message('Sldv:ModelSlicer:gui:StartingPoints'));
                    msg=getString(message('Sldv:ModelSlicer:SLSlicerAPI:InvalidSeedFoundWhenActivated',elem(idx).SID,handleType));
                    mex=MException('ModelSlicer:GUI:InvalidSeedFoundWhenActivatedSeeds',msg);
                    elem(idx)=[];

                    modelslicerprivate('MessageHandler','info',mex,modelName,true);
                    continue;
                end
                PortNum=get(elem(idx).Handle,'PortNumber');
                fPath=sprintf('%s:%d',getfullname(...
                get_param(elem(idx).Handle,'ParentHandle')),PortNum);
                if isfield(elem(idx),'BusElementPath')&&...
                    ~isempty(elem(idx).BusElementPath)
                    fPath=convertStringsToChars...
                    (strcat(fPath,"~",elem(idx).BusElementPath));
                end
                iconPath=sigIcon;
            end

            bpath=getPathColumn(elem(idx));

            itemIcon=getItemIcon(iconPath);
            itemPath=Advisor.Text(bpath);
            itemPath.Hyperlink=sprintf('matlab:SlicerConfiguration.hiliteSeed(''%s'',''%s'',%d);'...
            ,modelName,seedType,idx);

            tooltip=getToolTip(bpath,fPath,modelName,seedType,idx);

            if strcmp(seedType,'constraints')

                portNumbers=elem(idx).PortStruct.PortNumbers;



                BlockType=get_param(elem(idx).Handle,'BlockType');
                if strcmp(BlockType,'MultiPortSwitch')&&portNumbers(1)==1
                    portNumbers(1)=[];
                end

                porttip=getPortTip(portNumbers,modelName,elem(idx).Handle);
                seperator=getSeperator();
                portTipHTML=[seperator.emitHTML,porttip.emitHTML];
            else
                portTipHTML='';
            end


            delIcon=Advisor.Text(sprintf('<img id="%s%d" src="%s"/>',id,idx,whitepng));
            delIcon.Hyperlink=sprintf('matlab:SlicerConfiguration.deleteSeed(''%s'',''%s'',%d);'...
            ,modelName,seedType,idx);

            rowEntry=Advisor.Element;
            rowEntry.Tag='span';
            rowEntry.TagAttributes={...
            'onMouseOver',sprintf('mouseOverRow(%s%d)',id,idx);...
            'onMouseOut',sprintf('mouseOutRow(%s%d)',id,idx)};
            if lockedForInspect

                rowEntry.Content=[itemIcon.emitHTML,tooltip.emitHTML,portTipHTML];
            else
                rowEntry.Content=[itemIcon.emitHTML,tooltip.emitHTML,portTipHTML,delIcon.emitHTML];
            end
            table.setEntry(vidx,1,rowEntry)
            vidx=vidx+1;
        catch Mex %#ok<NASGU>

        end
    end
    if~valid
        sc.updateUserStartsFromStruct(elem);
    end
end
function itemIcon=getItemIcon(iconPath)

    itemIcon=Advisor.Image;
    itemIcon.ImageSource=iconPath;
end

function tooltip=getToolTip(bpath,fPath,modelName,seedType,idx)

    itemPath=Advisor.Text(bpath);
    itemPath.Hyperlink=sprintf('matlab:SlicerConfiguration.hiliteSeed(''%s'',''%s'',%d);'...
    ,modelName,seedType,idx);

    tooltip=Advisor.Element;
    tooltip.Content=itemPath;
    tooltip.Tag='span';
    tooltip.TagAttributes={'class','tooltip';'path',fPath};
end

function seperator=getSeperator()
    itemPath=Advisor.Text(getString(message('Sldv:ModelSlicer:gui:Colon')));
    seperator=Advisor.Element;
    seperator.Content=itemPath;
    seperator.Tag='span';
end

function tooltip=getPortTip(portNumbers,modelName,elemH)
    nSize=numel(portNumbers);

    if(nSize>3)
        fpath=getString(message('Sldv:ModelSlicer:gui:PortInfoGT3',portNumbers(1),portNumbers(2),...
        portNumbers(3)));
    elseif(nSize==3)
        fpath=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ3',portNumbers(1),portNumbers(2),...
        portNumbers(3)));
    elseif(nSize==2)
        fpath=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ2',portNumbers(1),portNumbers(2)));
    elseif(nSize==1)
        fpath=getString(message('Sldv:ModelSlicer:gui:PortInfoEQ1',portNumbers(1)));
    else

        fpath='edit';
    end

    itemPath=Advisor.Text(fpath);
    sid=Simulink.ID.getSID(elemH);

    itemPath.Hyperlink=sprintf('matlab:SlicerConfiguration.editConstraint(''%s'',''%s'');'...
    ,modelName,sid);

    tooltip=Advisor.Element;
    tooltip.Content=itemPath;
    tooltip.Tag='span';
    tooltip.TagAttributes={'class','tooltip';'path',...
    getString(message('Sldv:ModelSlicer:gui:ConstraintPortsToolTip'));};
end
