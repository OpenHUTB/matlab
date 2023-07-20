function dlgstruct=getDialogSchema(hUI,unused)%#ok<INUSD>




    block=hUI.getBlock;
    blockH=block.Handle;


    isLink=strcmpi(get_param(blockH,'LinkStatus'),'resolved');
    isLocked=strcmpi(get_param(bdroot(blockH),'Lock'),'on');
    isSimulating=any(strcmp(get_param((bdroot(blockH)),'SimulationStatus'),{'running','paused'}));
    isLockedOrSimulating=isLocked||isSimulating;
    isLockedByHarness=getLockedByHarnessState(blockH);


    descTxt.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogText');
    descTxt.Type='text';
    descTxt.WordWrap=true;
    descTxt.RowSpan=[1,1];
    descTxt.ColSpan=[1,14];

    configSetButton=struct('Type','pushbutton');
    configSetButton.Tag='csb_functionName_configSetButton_tag';
    configSetButton.ToolTip=DAStudio.message('Simulink:CustomCode:CFcnCallerConfigSetToolTip');
    configSetButton.FilePath=fullfile(matlabroot,'toolbox','shared',...
    'controllib','general','resources','Settings_16.png');
    configSetButton.ColSpan=[15,15];
    configSetButton.RowSpan=[1,1];
    configSetButton.MatlabMethod='SLCC.blocks.ui.FcnName.FunctionNameWidget.openToCustomCodeSettings';
    configSetButton.MatlabArgs={'%source','%dialog','%tag'};


    descGrp.Name='C Function';
    descGrp.Type='group';
    descGrp.Items={descTxt,configSetButton};
    descGrp.LayoutGrid=[1,15];
    descGrp.ColStretch=ones(1,15);
    descGrp.ColStretch([15])=0;
    descGrp.Enabled=~isLockedOrSimulating&&~isLink;




    cScript.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogcScriptName');
    cScript.Type='matlabeditor';
    cScript.MatlabEditorFeatures={'LineNumber'};
    cScript.Tag='OutputCode';
    cScript.ObjectProperty=cScript.Tag;
    cScript.Mode=true;
    cScript.Source=block;
    cScript.DialogRefresh=1;
    cScript.RowSpan=[1,1];
    cScript.ColSpan=[1,1];
    cScript.ToolTip=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogStatementDesc',cScript.Name);
    cScript.MatlabMethod='slDialogUtil';
    cScript.MatlabArgs={hUI,'sync','%dialog','edit','%tag'};
    cScript.Enabled=~isLink&&~isLockedOrSimulating&&~isLockedByHarness;

    startScript.Name='';
    startScript.Type='matlabeditor';
    startScript.MatlabEditorFeatures={'LineNumber'};
    startScript.Tag='StartCode';
    startScript.ObjectProperty=startScript.Tag;
    startScript.Mode=true;
    startScript.Source=block;
    startScript.DialogRefresh=1;
    startScript.RowSpan=[2,2];
    startScript.ColSpan=[1,1];
    startScript.Visible=true;
    startScript.ToolTip=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogStatementDesc',DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogstartScriptName'));
    startScript.MatlabMethod='slDialogUtil';
    startScript.MatlabArgs={hUI,'sync','%dialog','edit','%tag'};
    startScript.Enabled=~isLink&&~isLockedOrSimulating&&~isLockedByHarness;



    startScriptPanel.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogstartScriptName');
    if~isempty(strtrim(block.StartCode))
        startScriptPanel.Name=[startScriptPanel.Name,'*'];
    end
    startScriptPanel.Type='togglepanel';
    startScriptPanel.Items={startScript};
    startScriptPanel.Tag='Tag_StartScriptPanel';
    startScriptPanel.WidgetId='StartScriptPanel_widgetid';
    startScriptPanel.Visible=true;
    startScriptPanel.Expand=false;
    startScriptPanel.RowSpan=[2,2];
    startScriptPanel.ColSpan=[1,1];

    initScript.Name='';
    initScript.Type='matlabeditor';
    initScript.MatlabEditorFeatures={'LineNumber'};
    initScript.Tag='InitializeConditionsCode';
    initScript.ObjectProperty=initScript.Tag;
    initScript.Mode=true;
    initScript.Source=block;
    initScript.DialogRefresh=1;
    initScript.RowSpan=[3,3];
    initScript.ColSpan=[1,1];
    initScript.Visible=true;
    initScript.ToolTip=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogStatementDesc',DAStudio.message('Simulink:CustomCode:CFunctionBlockDialoginitScriptName'));
    initScript.MatlabMethod='slDialogUtil';
    initScript.MatlabArgs={hUI,'sync','%dialog','edit','%tag'};
    initScript.Enabled=~isLink&&~isLockedOrSimulating&&~isLockedByHarness;

    initScriptPanel.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialoginitScriptName');
    if~isempty(strtrim(block.InitializeConditionsCode))
        initScriptPanel.Name=[initScriptPanel.Name,'*'];
    end
    initScriptPanel.Type='togglepanel';
    initScriptPanel.Items={initScript};
    initScriptPanel.Tag='Tag_InitScriptPanel';
    initScriptPanel.WidgetId='InitScriptPanel_widgetid';
    initScriptPanel.Visible=true;
    initScriptPanel.Expand=false;
    initScriptPanel.RowSpan=[3,3];
    initScriptPanel.ColSpan=[1,1];

    termScript.Name='';
    termScript.Type='matlabeditor';
    termScript.MatlabEditorFeatures={'LineNumber'};
    termScript.Tag='TerminateCode';
    termScript.ObjectProperty=termScript.Tag;
    termScript.Mode=true;
    termScript.Source=block;
    termScript.DialogRefresh=1;
    termScript.RowSpan=[4,4];
    termScript.ColSpan=[1,1];
    termScript.Visible=true;
    termScript.ToolTip=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogStatementDesc',DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogtermScriptName'));
    termScript.MatlabMethod='slDialogUtil';
    termScript.MatlabArgs={hUI,'sync','%dialog','edit','%tag'};
    termScript.Enabled=~isLink&&~isLockedOrSimulating&&~isLockedByHarness;

    termScriptPanel.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogtermScriptName');
    if~isempty(strtrim(block.TerminateCode))
        termScriptPanel.Name=[termScriptPanel.Name,'*'];
    end
    termScriptPanel.Type='togglepanel';
    termScriptPanel.Items={termScript};
    termScriptPanel.Tag='Tag_TermScriptPanel';
    termScriptPanel.WidgetId='TermScriptPanel_widgetid';
    termScriptPanel.Visible=true;
    termScriptPanel.Expand=false;
    termScriptPanel.RowSpan=[4,4];
    termScriptPanel.ColSpan=[1,1];


    simGroup.Type='group';
    simGroup.Name=DAStudio.message('Simulink:CustomCode:CFunctionBlockDialogWidgetGroupTitle');
    simGroup.LayoutGrid=[3,2];

    simGroup.Items={cScript,startScriptPanel,initScriptPanel,termScriptPanel};
    simGroup.RowSpan=[1,1];
    simGroup.ColSpan=[1,1];
    simGroup.RowStretch=[1,0,0];


    portSpecPanel=SLCC.blocks.ui.PortSpec.CFcnDDGWidget;
    psWidget=portSpecPanel.getWidgetStruct(hUI,false);
    psWidget.Enabled=~isLink&&~isLockedOrSimulating&&~isLockedByHarness;
    psWidget.RowSpan=[2,2];



    sampleTime.Name=DAStudio.message('Simulink:blkprm_prompts:AllSrcBlksSampleTime');
    sampleTime.Type='edit';
    sampleTime.Tag='SampleTime';
    sampleTime.ObjectProperty=sampleTime.Tag;
    sampleTime.Mode=true;
    sampleTime.Source=block;
    sampleTime.DialogRefresh=1;
    sampleTime.RowSpan=[1,1];
    sampleTime.ColSpan=[1,1];
    sampleTime.Visible=true;
    sampleTime.MatlabMethod='slDialogUtil';
    sampleTime.MatlabArgs={hUI,'sync','%dialog','edit','%tag'};
    sampleTime.Enabled=~isLockedOrSimulating&&~isSampleTimePromoted(blockH);


    sampleTimeGrp.Type='group';
    sampleTimeGrp.Name='';
    sampleTimeGrp.LayoutGrid=[1,1];

    sampleTimeGrp.Items={sampleTime};
    sampleTimeGrp.RowSpan=[3,3];
    sampleTimeGrp.ColSpan=[1,1];


    dlgGroup.Type='group';
    dlgGroup.Name='';
    dlgGroup.LayoutGrid=[3,1];
    dlgGroup.Items={simGroup,psWidget,sampleTimeGrp};
    dlgGroup.RowSpan=[1,1];
    dlgGroup.ColSpan=[1,1];
    dlgGroup.RowStretch=[1,0,0];


    dlgstruct.DialogTag='Tag_CFBUI';
    dlgstruct.Items={descGrp,dlgGroup};


    dlgstruct.PreApplyMethod='preApplyCallback';
    dlgstruct.PreApplyArgs={'%dialog'};
    dlgstruct.PreApplyArgsDT={'handle'};

    dlgstruct.CloseMethod='closeCallback';
    dlgstruct.CloseMethodArgs={'%dialog'};
    dlgstruct.CloseMethodArgsDT={'handle'};

    dlgstruct.HelpMethod='helpview';
    dlgstruct.HelpArgs={fullfile(docroot,'simulink','helptargets.map'),'CFunction'};



    function isLockedByHarness=getLockedByHarnessState(blockH)
        syncMode=-1;
        isHarnessOpen=false;
        isHarnessCUT=slfeature('CFunctionBlockHarness')&&...
        ishandle(blockH)&&Simulink.harness.internal.isHarnessCUT(blockH);
        if isHarnessCUT

            syncMode=getSyncModeFromHarnessBlock(blockH);
        else

            hInfo=Simulink.harness.find(blockH,"OpenOnly","on");
            isHarnessOpen=~isempty(hInfo);
            anyHarnessWithImplicitSync=false;
            if isHarnessOpen
                for i=1:length(hInfo)
                    syncMode=hInfo(i).synchronizationMode;

                    if(~isequal(syncMode,2))
                        anyHarnessWithImplicitSync=true;
                        break;
                    end
                end

            end
        end
        lockHarness=isHarnessCUT&&isequal(syncMode,1);
        lockOwner=isHarnessOpen&&anyHarnessWithImplicitSync;
        isLockedByHarness=lockHarness||lockOwner;

        function syncMode=getSyncModeFromHarnessBlock(harnessBlockH)
            modelH=bdroot(harnessBlockH);
            ownerModelH=Simulink.harness.internal.getHarnessOwnerBD(modelH);
            hInfo=Simulink.harness.find(ownerModelH,"Name",get_param(modelH,"Name"));
            syncMode=hInfo.synchronizationMode;

            function isPromoted=isSampleTimePromoted(blockH)
                mask=get_param(blockH,'MaskObject');
                if(isempty(mask))
                    isPromoted=false;
                    return
                end

                sampleTimeMaskParam=mask.getParameter('SampleTime');
                if(isempty(sampleTimeMaskParam))
                    isPromoted=false;
                    return
                end
                isPromoted=true;


