function[tgtWidgets]=getSharedIDELinkExtensionDialogSchema(hSrc,isERT)




    tag=hSrc.getTagPrefix;

    if isempty(hSrc.getConfigSet().getComponent('Target Hardware Resources'))

        if~exist('registertic2000.m','file')&&...
            ~exist('registerxilinxise.m','file')
            dummywidget.Type='textbrowser';
            msg=DAStudio.message('ERRORHANDLER:pjtgenerator:NoSupportPackageInstalled');
            dummywidget.Text=(msg);
            dummywidget.Visible=1;
            dummywidget.Tag=[tag,'InvalidAdaptor'];
            tgtWidgets.Name=message('codertarget:build:CoderTargetName').getString;
            tgtWidgets.Items={dummywidget};
        else







            dummywidget.Type='textbrowser';
            dummywidget.Text=('This text will never be displayed');
            dummywidget.Visible=0;
            dummywidget.Tag=[tag,'InvalidAdaptor'];
            tgtWidgets.Name=message('codertarget:build:CoderTargetName').getString;
            tgtWidgets.Items={dummywidget};
        end

    elseif hSrc.ProjectMgr.mAdaptorRegistry.isValidAdaptorName(hSrc.AdaptorName)





        IDEGroup.Name=message('IDELINKCONFIG:parameters:ToolChainName').getString;
        IDEGroup.Type='group';
        IDEGroup.LayoutGrid=[4,1];
        IDEGroup.RowStretch=[0,0,0,1];
        IDEGroup.Visible=false;


        widget.Name=message('IDELINKCONFIG:parameters:AdaptorNameName').getString;
        widget.Type='combobox';
        widget.Entries=hSrc.ProjectMgr.getAdaptorNames;
        widget.Values=0:length(widget.Entries)-1;
        widget.ObjectProperty='AdaptorName';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.Enabled=true;
        widget.Visible=false;
        widget.ToolTip=message('IDELINKCONFIG:parameters:AdaptorNameToolTip').getString;
        widget.RowSpan=[1,1];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        supportedIDE=widget;
        widget=[];

        IDEGroup.Items={supportedIDE};




        TargetSelGroup.Name=message('IDELINKCONFIG:parameters:ToolChainAutomationGroup').getString;
        TargetSelGroup.Type='group';
        TargetSelGroup.LayoutGrid=[4,1];
        TargetSelGroup.RowStretch=[0,0,0,1];



        widget.Name=[message('IDELINKCONFIG:parameters:ideObjBuildTimeoutName').getString,'                  '];
        widget.Type='edit';
        widget.ObjectProperty='ideObjBuildTimeout';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty)&&...
        ~strcmpi(hSrc.buildAction,'Create_project');
        widget.RowSpan=[1,1];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:ideObjBuildTimeoutToolTip').getString;
        ideObjBuildTimeout=widget;
        widget=[];

        widget.Name=message('IDELINKCONFIG:parameters:ideObjTimeoutName').getString;
        widget.Type='edit';
        widget.ObjectProperty='ideObjTimeout';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[2,2];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:ideObjTimeoutToolTip').getString;
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        ideObjTimeout=widget;
        widget=[];

        widget.Name=message('IDELINKCONFIG:parameters:exportIDEObjName').getString;
        widget.Type='checkbox';
        widget.ObjectProperty='exportIDEObj';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[3,3];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:exportIDEObjToolTip').getString;
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        exportIDEObj=widget;
        widget=[];

        widget.Name=message('IDELINKCONFIG:parameters:ideObjNameName').getString;
        widget.Type='edit';
        widget.ObjectProperty='ideObjName';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty)&&strcmp(hSrc.exportIDEObj,'on');
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[4,4];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:ideObjNameToolTip').getString;
        ideObjName=widget;
        widget=[];

        TargetSelGroup.Items={ideObjBuildTimeout,ideObjTimeout,exportIDEObj,ideObjName};


        TargetSelGroup.Visible=getVisibleFlag(hSrc,'group',TargetSelGroup);




        CodeGenGroup.Name=message('RTW:configSet:configSetCodeGen').getString;
        CodeGenGroup.Type='group';
        CodeGenGroup.LayoutGrid=[4,1];
        CodeGenGroup.RowStretch=[0,0,0,1];


        widget.Name=message('IDELINKCONFIG:parameters:ProfileGenCodeName').getString;
        widget.Type='checkbox';
        widget.ObjectProperty='ProfileGenCode';
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[1,1];
        widget.ColSpan=[1,1];
        widget.ToolTip=message('IDELINKCONFIG:parameters:ProfileGenCodeToolTip').getString;
        ProfileGenCode=widget;
        widget=[];


        widget.Name=message('IDELINKCONFIG:parameters:profileByName').getString;
        widget.Type='combobox';
        widget.Entries={'Tasks','Atomic subsystems'};
        widget.Values=[0,1];
        widget.ObjectProperty='profileBy';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.ToolTip=message('IDELINKCONFIG:parameters:profileByToolTip').getString;
        widget.RowSpan=[2,2];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        ProfileBy=widget;
        widget=[];

        widget.Name=message('IDELINKCONFIG:parameters:ProfileNumSamplesName').getString;
        widget.Type='edit';
        widget.ObjectProperty='ProfileNumSamples';
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.Tag=[tag,widget.ObjectProperty];
        widget.RowSpan=[3,3];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:ProfileNumSamplesToolTip').getString;
        ProfileNumSamples=widget;
        widget=[];




        widget.Name=message('IDELINKCONFIG:parameters:InlineDSPBlksName').getString;
        widget.Type='checkbox';
        widget.Visible=false;
        widget.ObjectProperty='InlineDSPBlks';
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Tag=[tag,widget.ObjectProperty];
        widget.RowSpan=[4,4];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:InlineDSPBlksToolTip').getString;
        InlineDSPBlks=widget;
        widget=[];

        CodeGenGroup.Items={ProfileGenCode,ProfileBy,ProfileNumSamples,InlineDSPBlks};


        CodeGenGroup.Visible=getVisibleFlag(hSrc,'group',CodeGenGroup);




        ProjectGroup.Name=message('IDELINKCONFIG:parameters:VendorToolChainGroup').getString;
        ProjectGroup.Type='group';
        ProjectGroup.LayoutGrid=[5,5];
        ProjectGroup.RowStretch=[0,0,0,0,1];


        widget.Name=[message('IDELINKCONFIG:parameters:projectOptionsName').getString,ascii_tab(2)];
        widget.Type='combobox';
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.Entries={'Debug','Release','Custom'};
        widget.Values=[0,1,2];
        widget.ObjectProperty='projectOptions';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[1,1];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.ToolTip=message('IDELINKCONFIG:parameters:projectOptionsToolTip').getString;
        projectOptions=widget;
        widget=[];

        widget.Name=[message('IDELINKCONFIG:parameters:compilerOptionsStrName').getString,ascii_tab(1)];
        widget.Type='edit';
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.ObjectProperty='compilerOptionsStr';
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.RowSpan=[2,2];
        widget.ColSpan=[1,1];
        widget.ToolTip=message('IDELINKCONFIG:parameters:compilerOptionsStrToolTip').getString;
        compilerOptionsStr=widget;
        widget=[];

        getCompilerOptions.Name=message('IDELINKCONFIG:parameters:getCompilerOptionsName').getString;
        getCompilerOptions.Type='pushbutton';
        ObjectProperty='getCompilerOptions';
        getCompilerOptions.Enabled=getEnabledFlag(hSrc,ObjectProperty);
        getCompilerOptions.Visible=getVisibleFlag(hSrc,ObjectProperty);
        getCompilerOptions.Tag=[tag,ObjectProperty];
        getCompilerOptions.ObjectMethod='tgtDialogCallback';
        getCompilerOptions.MethodArgs={'%dialog',getCompilerOptions.Tag,''};
        getCompilerOptions.ArgDataTypes={'handle','string','string'};
        getCompilerOptions.RowSpan=[2,2];
        getCompilerOptions.ColSpan=[2,2];
        getCompilerOptions.Mode=1;
        getCompilerOptions.DialogRefresh=1;
        getCompilerOptions.ToolTip=message('IDELINKCONFIG:parameters:getCompilerOptionsToolTip').getString;

        resetCompilerOptions.Name=message('IDELINKCONFIG:parameters:resetCompilerOptionsName').getString;
        resetCompilerOptions.Type='pushbutton';
        ObjectProperty='resetCompilerOptions';
        resetCompilerOptions.Enabled=~strcmpi(hSrc.projectOptions,'Custom')&&getEnabledFlag(hSrc,ObjectProperty);
        resetCompilerOptions.Visible=getVisibleFlag(hSrc,ObjectProperty);
        resetCompilerOptions.Tag=[tag,ObjectProperty];
        resetCompilerOptions.ObjectMethod='tgtDialogCallback';
        resetCompilerOptions.MethodArgs={'%dialog',resetCompilerOptions.Tag,''};
        resetCompilerOptions.ArgDataTypes={'handle','string','string'};
        resetCompilerOptions.RowSpan=[2,2];
        resetCompilerOptions.ColSpan=[3,3];
        resetCompilerOptions.Mode=1;
        resetCompilerOptions.DialogRefresh=1;
        resetCompilerOptions.ToolTip=message('IDELINKCONFIG:parameters:resetCompilerOptionsToolTip').getString;

        widget.Name=[message('IDELINKCONFIG:parameters:linkerOptionsStrName').getString,ascii_tab(1)];
        widget.Type='edit';
        widget.ObjectProperty='linkerOptionsStr';
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.RowSpan=[3,3];
        widget.ColSpan=[1,1];
        widget.Mode=1;
        widget.DialogRefresh=1;
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.ToolTip=message('IDELINKCONFIG:parameters:linkerOptionsStrToolTip').getString;
        linkerOptionsStr=widget;
        widget=[];

        getLinkerOptions.Name=message('IDELINKCONFIG:parameters:getLinkerOptionsName').getString;
        getLinkerOptions.Type='pushbutton';
        ObjectProperty='getLinkerOptions';
        getLinkerOptions.Enabled=getEnabledFlag(hSrc,ObjectProperty);
        getLinkerOptions.Visible=getVisibleFlag(hSrc,ObjectProperty);
        getLinkerOptions.Tag=[tag,ObjectProperty];
        getLinkerOptions.ObjectMethod='tgtDialogCallback';
        getLinkerOptions.MethodArgs={'%dialog',getLinkerOptions.Tag,''};
        getLinkerOptions.ArgDataTypes={'handle','string','string'};
        getLinkerOptions.RowSpan=[3,3];
        getLinkerOptions.ColSpan=[2,2];
        getLinkerOptions.Mode=1;
        getLinkerOptions.DialogRefresh=1;
        getLinkerOptions.ToolTip=message('IDELINKCONFIG:parameters:getLinkerOptionsToolTip').getString;

        resetLinkerOptions.Name=message('IDELINKCONFIG:parameters:resetLinkerOptionsName').getString;
        resetLinkerOptions.Type='pushbutton';
        ObjectProperty='resetLinkerOptions';
        resetLinkerOptions.Enabled=~strcmpi(hSrc.projectOptions,'Custom')&&getEnabledFlag(hSrc,ObjectProperty);
        resetLinkerOptions.Visible=getVisibleFlag(hSrc,ObjectProperty);
        resetLinkerOptions.Tag=[tag,ObjectProperty];
        resetLinkerOptions.ObjectMethod='tgtDialogCallback';
        resetLinkerOptions.MethodArgs={'%dialog',resetLinkerOptions.Tag,''};
        resetLinkerOptions.ArgDataTypes={'handle','string','string'};
        resetLinkerOptions.RowSpan=[3,3];
        resetLinkerOptions.ColSpan=[3,3];
        resetLinkerOptions.Mode=1;
        resetLinkerOptions.DialogRefresh=1;
        resetLinkerOptions.ToolTip=message('IDELINKCONFIG:parameters:resetLinkerOptionsToolTip').getString;

        systemStackSize.Name=[message('IDELINKCONFIG:parameters:systemStackSizeName').getString,ascii_tab(1)];
        systemStackSize.Type='edit';
        systemStackSize.ObjectProperty='systemStackSize';
        systemStackSize.Enabled=getEnabledFlag(hSrc,systemStackSize.ObjectProperty);
        systemStackSize.Visible=getVisibleFlag(hSrc,systemStackSize.ObjectProperty);
        systemStackSize.RowSpan=[4,4];
        systemStackSize.ColSpan=[1,1];
        systemStackSize.Alignment=1;
        systemStackSize.Mode=1;
        systemStackSize.DialogRefresh=1;
        systemStackSize.Tag=[tag,'systemStackSize'];
        systemStackSize.ToolTip=message('IDELINKCONFIG:parameters:systemStackSizeToolTip').getString;

        systemHeapSize.Name=[message('IDELINKCONFIG:parameters:systemHeapSizeName').getString,ascii_tab(1)];
        systemHeapSize.Type='edit';
        systemHeapSize.ObjectProperty='systemHeapSize';
        systemHeapSize.Enabled=getEnabledFlag(hSrc,systemHeapSize.ObjectProperty);
        systemHeapSize.Visible=getVisibleFlag(hSrc,systemHeapSize.ObjectProperty);
        systemHeapSize.RowSpan=[5,5];
        systemHeapSize.ColSpan=[1,1];
        systemHeapSize.Alignment=1;
        systemHeapSize.Mode=1;
        systemHeapSize.DialogRefresh=1;
        systemHeapSize.Tag=[tag,'systemHeapSize'];
        systemHeapSize.ToolTip=message('IDELINKCONFIG:parameters:systemHeapSizeToolTip').getString;

        ProjectGroup.Items={projectOptions,...
        compilerOptionsStr,getCompilerOptions,resetCompilerOptions,...
        linkerOptionsStr,getLinkerOptions,resetLinkerOptions,systemStackSize,systemHeapSize};


        ProjectGroup.Visible=getVisibleFlag(hSrc,'group',ProjectGroup);





        nRows=3+isERT;
        RuntimeGroup.Name=message('IDELINKCONFIG:parameters:RunTimeGroup').getString;
        RuntimeGroup.Type='group';
        RuntimeGroup.LayoutGrid=[nRows,1];
        RuntimeGroup.RowStretch=[zeros(1,nRows-1),1];


        widget.Name=[message('IDELINKCONFIG:parameters:buildFormatName').getString,ascii_tab(1)];
        widget.Type='combobox';
        widget.Entries={'Project','Makefile'};
        widget.Values=[0,1];
        widget.ObjectProperty='buildFormat';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.Enabled=hSrc.ProjectMgr.getAdaptorSpecificInfo(hSrc.AdaptorName,'getBuildFormatEnable');
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.ToolTip=message('IDELINKCONFIG:parameters:buildFormatToolTip').getString;
        widget.RowSpan=[1,1];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        buildFormat=widget;
        widget=[];


        widget.Name=[message('IDELINKCONFIG:parameters:buildActionName').getString,ascii_tab(1)];
        widget.Type='combobox';
        widget.Entries=getEntriesForBuildAction(hSrc,isERT);
        widget.Values=(0:numel(widget.Entries)-1);
        widget.ObjectProperty='buildAction';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.ToolTip=message('IDELINKCONFIG:parameters:buildActionToolTip').getString;
        widget.RowSpan=[2,2];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        buildAction=widget;
        widget=[];

        widget.Name=[message('IDELINKCONFIG:parameters:overrunNotificationMethodName').getString,ascii_space(1)];
        widget.Type='combobox';
        widget.ObjectProperty='overrunNotificationMethod';
        widget.Entries={'None','Print_message','Call_custom_function'};
        widget.Values=[0,1,2];
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ToolTip=message('IDELINKCONFIG:parameters:overrunNotificationMethodToolTip').getString;
        widget.RowSpan=[3,3];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        overrunNotificationMethod=widget;
        widget=[];

        widget.Name=[message('IDELINKCONFIG:parameters:overrunNotificationFcnName').getString,ascii_space(1)];
        widget.Type='edit';
        widget.ObjectProperty='overrunNotificationFcn';
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty)&&strcmpi(hSrc.overrunNotificationMethod,'Call_custom_function');
        widget.Tag=[tag,widget.ObjectProperty];
        widget.ObjectMethod='tgtDialogCallback';
        widget.MethodArgs={'%dialog',widget.Tag,''};
        widget.ArgDataTypes={'handle','string','string'};
        widget.ToolTip=message('IDELINKCONFIG:parameters:overrunNotificationFcnToolTip').getString;
        widget.RowSpan=[3,3];
        widget.ColSpan=[2,2];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        overrunNotificationFcn=widget;
        widget=[];

        RuntimeGroup.Items={buildFormat,buildAction,overrunNotificationMethod,overrunNotificationFcn};


        RuntimeGroup.Visible=getVisibleFlag(hSrc,'group',RuntimeGroup);





        DiagnosticGroup.Name=message('RTW:configSet:configSetDiagnostics').getString;
        DiagnosticGroup.Type='group';
        DiagnosticGroup.LayoutGrid=[2,1];
        DiagnosticGroup.RowStretch=[0,1];

        widget.Name=message('IDELINKCONFIG:parameters:DiagnosticActionsName').getString;
        widget.Type='combobox';
        widget.Entries={'none','warning','error'};
        widget.Values=[0,1,2];
        widget.ObjectProperty='DiagnosticActions';
        widget.Tag=[tag,widget.ObjectProperty];
        widget.Enabled=getEnabledFlag(hSrc,widget.ObjectProperty);
        widget.Visible=getVisibleFlag(hSrc,widget.ObjectProperty);
        widget.ToolTip=message('IDELINKCONFIG:parameters:DiagnosticActionsToolTip').getString;
        widget.RowSpan=[1,2];
        widget.ColSpan=[1,1];
        widget.Alignment=1;
        widget.Mode=1;
        widget.DialogRefresh=1;
        DiagnosticActions=widget;
        widget=[];%#ok<NASGU>

        DiagnosticGroup.Items={DiagnosticActions};


        DiagnosticGroup.Visible=getVisibleFlag(hSrc,'group',DiagnosticGroup);





        TargetHardwareResourcesGroup.Name=message('IDELINKCONFIG:parameters:TargetResourcesGroup').getString;
        TargetHardwareResourcesGroup.Type='group';
        TargetHardwareResourcesGroup.LayoutGrid=[1,1];


        TargetHardwareResourcesGroup.Visible=1;




        IDEGroup.RowSpan=[1,1];
        RuntimeGroup.RowSpan=[2,2];
        ProjectGroup.RowSpan=[3,3];
        CodeGenGroup.RowSpan=[4,4];
        TargetSelGroup.RowSpan=[5,5];
        DiagnosticGroup.RowSpan=[6,6];

        Panel1.Name=message('IDELINKCONFIG:parameters:ToolChainAutomationGroup').getString;
        Panel1.Type='panel';
        Panel1.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Link';
        Panel1.Items={IDEGroup,RuntimeGroup,ProjectGroup,CodeGenGroup,TargetSelGroup,DiagnosticGroup};
        Panel1.LayoutGrid=[7,1];
        Panel1.RowStretch=[0,0,0,0,0,0,1];

        tab1.Name=message('IDELINKCONFIG:parameters:ToolChainAutomationGroup').getString;
        tab1.Items={Panel1};




        cs=hSrc.getParent().getParent();
        if isempty(get_param(cs,'TargetHardwareResources'))
            linkfoundation.util.initializeTargetHardwareResources(cs);
        end

        controller=get_param(cs,'TargetHardwareResourcesController');
        if isempty(controller)
            controller=targetpref.Controller.get(cs,-1,'emptyFcn');
            set_param(cs,'TargetHardwareResourcesController',controller);
        end

        if(~controller.getData().isProcRegistered())
            newGroup.Name=message('codertarget:build:CoderTargetName').getString;
            newGroup.Type='group';
            newGroup.LayoutGrid=[3,1];
            newGroup.RowStretch=[0,0,1];

            AllKnownChips=controller.getChipNameList();
            if~isempty(AllKnownChips)
                textlbl=DAStudio.message('ERRORHANDLER:tgtpref:ChipNotRegistered',...
                controller.getData().getCurChipName(),AllKnownChips{1},AllKnownChips{1});
            else
                textlbl=DAStudio.message('ERRORHANDLER:tgtpref:InvalidProcessorSet',...
                controller.getData().getCurChipName());
            end

            text1.Type='text';
            text1.Name=textlbl;
            text1.Visible=1;
            text1.RowSpan=[1,1];
            text1.ColSpan=[1,1];
            text1.Tag=[tag,'ProcessorNotRegistered'];

            controller.createView();

            button.Type='pushbutton';
            button.Name=message('IDELINKCONFIG:parameters:SwitchProcessorName').getString;
            button.Tag=['QuestDlg_','SwitchUnregisteredProcessor'];
            button.Source=controller.getView();
            button.ObjectMethod='callController';
            button.MethodArgs={'%dialog','switchUnregisteredProcessor',button.Tag,AllKnownChips,'',''};
            button.ArgDataTypes={'handle','mxArray','mxArray','mxArray','mxArray','mxArray'};
            button.RowSpan=[2,2];
            button.ColSpan=[1,1];
            button.Alignment=1;
            button.DialogRefresh=1;

            newGroup.Items={text1,button};

            Panel2.Name=message('codertarget:build:CoderTargetName').getString;
            Panel2.Type='panel';
            Panel2.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Link';
            Panel2.Items={newGroup};
            Panel2.LayoutGrid=[1,1];

            tgtWidgets.Name=message('codertarget:build:CoderTargetName').getString;
            tgtWidgets.Items={Panel2};
            tgtWidgets.LayoutGrid=[1,1];
        else
            controller.initializeData(cs);
            controller.createView();
            view=controller.getView();
            view.mCurTab=cs.getProp('TargetResourceManagerActiveTab');
            viewschema=view.getTargetPrefDialogSchema('TargetPrefView');

            items=viewschema.Items;

            TargetHardwareResourcesGroup.Items={items{1},items{2}};

            Panel2.Name=message('IDELINKCONFIG:parameters:TargetHWResourcesGroup').getString;
            Panel2.Type='panel';
            Panel2.Tag='Tag_ConfigSet_RTW_Target_Resources_Panel';
            Panel2.Items={TargetHardwareResourcesGroup};
            Panel2.LayoutGrid=[2,1];
            Panel2.RowStretch=[0,1];

            tab2.Name=message('IDELINKCONFIG:parameters:TargetHWResourcesGroup').getString;
            tab2.Items={Panel2};


            tabs.Name=message('codertarget:build:CoderTargetName').getString;
            tabs.Type='tab';
            tabs.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Tabs';
            tabs.Tabs={tab1,tab2};

            Panel3.Name=message('codertarget:build:CoderTargetName').getString;
            Panel3.Type='panel';
            Panel3.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Link3';
            Panel3.Items={tabs};
            Panel3.LayoutGrid=[1,1];
            Panel3.RowStretch=0;

            tgtWidgets=Panel3;

            if~isempty(controller.getWaitbar())
                controller.closeWaitbar();
            end
        end
    else
        if~exist('registertic2000.m','file')&&...
            ~exist('registerxilinxise.m','file')
            dummywidget.Type='textbrowser';
            msg=DAStudio.message('ERRORHANDLER:pjtgenerator:NoSupportPackageInstalled');
            dummywidget.Text=(msg);
            dummywidget.Visible=1;
            dummywidget.Tag=[tag,'InvalidAdaptor'];
            tgtWidgets.Name=message('codertarget:build:CoderTargetName').getString;
            tgtWidgets.Items={dummywidget};
        else

            IDEGroup.Name=message('codertarget:build:CoderTargetName').getString;
            IDEGroup.Type='group';
            IDEGroup.LayoutGrid=[1,1];
            IDEGroup.Visible=true;

            widget.Type='textbrowser';

            if strcmpi(hSrc.AdaptorName,'none')
                widget.Text=DAStudio.message('ERRORHANDLER:pjtgenerator:AdaptorNameNone');
            else
                msg=linkfoundation.util.throwDeprecationMessage('AdaptorNotInstalled',hSrc.AdaptorName);
                widget.Text=getString(msg);
            end

            widget.Visible=1;
            widget.RowSpan=[3,3];
            widget.ColSpan=[2,2];
            widget.Tag=[tag,'InvalidAdaptor'];
            ideWarningText=widget;
            widget=[];%#ok<NASGU>

            IDEGroup.Items={ideWarningText};

            Panel1.Name=message('codertarget:build:CoderTargetName').getString;
            Panel1.Type='panel';
            Panel1.Tag='Tag_ConfigSet_RTW_Embedded_IDE_Link';
            Panel1.Items={IDEGroup};
            Panel1.LayoutGrid=[1,1];
            Panel1.RowStretch=0;

            tgtWidgets.Name=message('codertarget:build:CoderTargetName').getString;
            tgtWidgets.Items={Panel1};
            tgtWidgets.LayoutGrid=[1,1];
        end
    end
end



function t=ascii_tab(n)
    t=char(ones(1,n)*9);
end



function s=ascii_space(n)
    s=char(ones(1,n)*32);
end



function entries=getEntriesForBuildAction(hSrc,isERT)
    entries=hSrc.ProjectMgr.getBuildActions(hSrc.AdaptorName,hSrc.buildFormat);
    if~isERT

        entries=entries(~strcmpi(entries,'Create_Processor_In_the_Loop_project'));
    end
end


