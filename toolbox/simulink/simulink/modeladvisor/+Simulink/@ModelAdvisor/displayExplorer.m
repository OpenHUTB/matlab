function displayExplorer(this,varargin)



















    if this.parallel
        return;
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Init GUI',true);

    mp=ModelAdvisor.Preferences;

    if(nargin>1&&strcmpi(varargin{1},'hide'))
        ShowGUI=false;
    else
        ShowGUI=true;
    end









    dbStackInfo=dbstack('-completenames');
    liteUICall=false;
    for i=1:length(dbStackInfo)
        if~isempty(strfind(dbStackInfo(i).file,'GUIModelAdvisorLite'))
            liteUICall=true;
        end
    end


    if this.NOBROWSER||isa(this.ConfigUIWindow,'DAStudio.Explorer')
        return
    end



    if slfeature('AdvisorWebUI')==1&&(strcmp(this.CustomTARootID,'_modeladvisor_')||startsWith(this.CustomTARootID,'_SYSTEM'))
        if isempty(this.AdvisorWindow)||~this.AdvisorWindow.isOpen()
            this.AdvisorWindow=Advisor.AdvisorWindow(this.ModelName);
            this.AdvisorWindow.setSystem(this.SystemName);
            this.AdvisorWindow.setConfiguration(this.ConfigFilePath);
            this.AdvisorWindow.open(ShowGUI,this);
        end
        return;
    end

    me=this.MAExplorer;

    MAExplorecreated=false;
    if~isa(me,'DAStudio.Explorer')
        if this.ShowProgressbar&&~liteUICall

            if isfield(this.AtticData,'Progressbar')&&~isempty(this.AtticData.Progressbar)
                close(this.AtticData.Progressbar);
                this.AtticData.Progressbar=[];
            end

            Progressbar=waitbar(0.5,DAStudio.message('ModelAdvisor:engine:StartMdlAdv'),'Name',DAStudio.message('Simulink:tools:MAInitializing'));
            this.AtticData.Progressbar=Progressbar;

        end

        MAExplorecreated=true;
        me=DAStudio.Explorer(this.TaskAdvisorRoot,'Model Advisor',false);

        screenSize=get(0,'ScreenSize');
        height=screenSize(4);
        width=screenSize(3);
        x=floor(width/6);
        y=floor(height/6);
        if width>1920
            width=1920;
        end
        if height>1200
            height=1200;
        end
        if width>1280
            height=floor(height/1.5);
            width=floor(width/1.5);
        else
            height=floor(height*0.8);
            width=floor(width*0.8);
        end
        me.position=[x,y,width,height];
        if~isempty(this.MAExplorerPosition)
            me.position=this.MAExplorerPosition;
        else
            this.MAExplorerPosition=me.position;
        end

        me.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','ma.png');

        this.listener{end+1}=handle.listener(me,'MEDelete',{@MECallback});

        this.listener{end+1}=handle.listener(me,'MEPostClosed',{@MECallback});

        this.listener{end+1}=handle.listener(me,'METreeSelectionChanged',{@MECallback});
        this.listener{end+1}=handle.listener(me,'MEPostFocus',{@MECallback});










        if this.ShowProgressbar&&isfield(this.AtticData,'Progressbar')&&~isempty(this.AtticData.Progressbar)&&ishandle(this.AtticData.Progressbar)
            close(this.AtticData.Progressbar);
            this.AtticData.Progressbar=[];
        end

    end

    me.setRoot(this.TaskAdvisorRoot);










    if MAExplorecreated
        createMenuToolbar(this,me);


        ByPNode=this.getTaskObj('_SYSTEM_By Product','-CreateObjectIfNotFound',false);
        if~isempty(ByPNode)
            if mp.ShowByProduct
                modeladvisorprivate('modeladvisorutil2','dynamic_attach_node',ByPNode.ParentObj,ByPNode);
            else
                modeladvisorprivate('modeladvisorutil2','dynamic_detach_node',ByPNode.ParentObj,ByPNode);
            end
        end
        ByTNode=this.getTaskObj('_SYSTEM_By Task','-CreateObjectIfNotFound',false);
        if~isempty(ByTNode)
            if mp.ShowByTask
                modeladvisorprivate('modeladvisorutil2','dynamic_attach_node',ByTNode.ParentObj,ByTNode);
            else
                modeladvisorprivate('modeladvisorutil2','dynamic_detach_node',ByTNode.ParentObj,ByTNode);
            end
        end
        edp=DAStudio.EventDispatcher;
        edp.broadcastEvent('HierarchyChangedEvent',this.TaskAdvisorRoot);


        this.ShowSourceTab=mp.ShowSourceTab;
        this.ShowExclusionTab=mp.ShowExclusionTab;
        this.ShowExclusions=mp.ShowExclusionsInRpt;








        this.MAExplorer=me;
        saveStage=this.Stage;
        this.Stage='InitMAExplorer';
        modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',me);
        this.Stage=saveStage;

        imme=DAStudio.imExplorer(me);
        selectedNode=Advisor.Utils.convertMCOS(imme.getCurrentTreeNode);
        if(isa(selectedNode,'ModelAdvisor.Node'))
            informerGUI=selectedNode.updateResultGUI('get');
            if isa(informerGUI,'DAStudio.Informer')
                informerGUI.delete;
            end
            selectedNode.updateResultGUI;
        end

        if this.IsLibrary
            LibPrefix=[DAStudio.message('ModelAdvisor:engine:Library'),': '];

            fp=get_param(bdroot(this.System),'ObjectParameters');
            if isfield(fp,'BlockDiagramType')
                if strcmpi(get_param(bdroot(this.System),'BlockDiagramType'),'subsystem')
                    LibPrefix=[DAStudio.message('ModelAdvisor:engine:Subsystem'),': '];
                end
            end
        else
            LibPrefix='';
        end
        GUITitle=DAStudio.message('Simulink:tools:MAModelAdvisor');
        if~isempty(this.CustomObject)&&~isempty(this.CustomObject.GUITitle)
            GUITitle=this.CustomObject.GUITitle;
        end
        me.Title=[GUITitle,' - ',LibPrefix,strrep(getfullname(this.System),newline,' ')];
        if~isempty(this.ConfigFilePath)
            me.Title=[me.Title,'  ',this.ConfigFilePath];
        end


        me.setTreeTitle('');
    end

    this.MAExplorer=me;

    mp=ModelAdvisor.Preferences;
    if mp.ShowAccordion
        for i=1:length(this.advertisements)
            if(this.advertisements(i).visible)
                me.addAccordionPane(this.advertisements(i).id,...
                this.advertisements(i).DisplayName,...
                this.advertisements(i).icon,...
                this.advertisements(i).Description);
                this.advertisements(i).OnGUI=true;
                me.showAccordionPane(this.advertisements(i).id);
            end
        end
        this.listener{end+1}=handle.listener(me,'MEAccordionPanelChanged',{@MECallback});
    end


    me.showListView(false);
    if~liteUICall
        ModelAdvisorLite.GUIModelAdvisorLite.closeGUI(this.System);
        if ShowGUI
            me.show;
        end

        if strcmp(this.customTARootID,'com.mathworks.cgo.group')
            this.MAExplorer.removeAccordionPane('com.mathworks.cgo.group');
        end
    end

    if~isempty(this.ConfigFilePath)
        for i=1:length(this.advertisements)
            if this.advertisements(i).OnGUI
                me.removeAccordionPane(this.Advertisements(i).id);
                this.advertisements(i).OnGUI=false;
            end
        end
    end
    drawnow;
    Simulink.ModelAdvisor.getActiveModelAdvisorObj(this);

    PerfTools.Tracer.logMATLABData('MAGroup','Init GUI',false);


    function MECallback(this,event)
        switch(event.type)
        case 'MEPostFocus'

            mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);
            Simulink.ModelAdvisor.getFocusModelAdvisorObj(mdladvObj);
        case 'MEDelete'

            mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);

            parallelRun=ModelAdvisor.ParallelRun.getInstance();
            parallelRun.stop();


            dialogObj=ModelAdvisor.MAOptions.findExistingDlg('');
            if~isempty(dialogObj)
                dialogObj.fDialogHandle.delete;
            end

            if~isempty(mdladvObj.CustomObject)&&~isempty(mdladvObj.CustomObject.GUICloseCallback)
                modeladvisorprivate('modeladvisorutil2','ProcessCallbackFcn',mdladvObj.CustomObject.GUICloseCallback,mdladvObj);
            end

            mdladvObj.MAExplorerPosition=this.Position;
            if isa(mdladvObj.ResultGUI,'DAStudio.Informer')
                try
                    slprivate('remove_hilite',bdroot(mdladvObj.SystemHandle));
                catch %#ok<CTCH> 815942

                end
                mdladvObj.ResultGUI.delete;
            end
            if isa(mdladvObj.ListExplorer,'DAStudio.Explorer')
                mdladvObj.ListExplorer.delete;
            end
            if isa(mdladvObj.RPObj,'ModelAdvisor.RestorePoint')
                mdladvObj.RPObj.delete;
            end
            mdladvObj.MEMenus={};

            if~isa(mdladvObj.ConfigUIWindow,'DAStudio.Explorer')
                Simulink.ModelAdvisor.getActiveModelAdvisorObj([]);
                Simulink.ModelAdvisor.getFocusModelAdvisorObj([]);
            end
            this.delete;
        case 'METreeSelectionChanged'
            modeladvisorprivate('modeladvisorutil2','UpdateMEMenuToolbar',this);

        case 'MEPostClosed'
            mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);
            me=mdladvObj.MAExplorer;
            if~isempty(me.UserData.findText)
                me.UserData.findText.setText('');
                me.UserData.filterCriteriaComboBoxWidget.setCurrentText('');
            end
            if strncmp(mdladvObj.CustomTARootID,'com.mathworks.HDL.',18)

                hdladvisor(mdladvObj.System,'Cleanup');
            end

            if~isempty(mdladvObj.CustomObject)&&~isempty(mdladvObj.CustomObject.GUICloseCallback)
                modeladvisorprivate('modeladvisorutil2','ProcessCallbackFcn',mdladvObj.CustomObject.GUICloseCallback,mdladvObj);
            end
        case 'MEAccordionPanelChanged'
            mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);
            if mdladvObj.isSleeping
                return;
            end
            if strcmp(event.EventData,'com.mathworks.Simulink.PerformanceAdvisor.PerformanceAdvisor')
                performanceadvisor(mdladvObj.System);
            elseif strcmp(event.EventData,'com.mathworks.Simulink.UpgradeAdvisor.UpgradeAdvisor')
                upgradeadvisor(mdladvObj.System);
            elseif strcmp(event.EventData,'com.mathworks.cgo.group')
                coder.advisor.internal.runBuildAdvisor(mdladvObj.System,true,false);
            elseif strcmp(event.EventData,'modeladvisor')
                modeladvisor(mdladvObj.System);
            end

        otherwise
            DAStudio.error('Simulink:tools:MAUnknownEventReceived');
        end

        function createMenuToolbar(this,me)
            am=DAStudio.ActionManager;
            am.initializeClient(me);


            m_file=am.createPopupMenu(me);

            if strncmp(this.CustomTARootID,'com.mathworks.HDL.',18)
                T_openNewSubsystem=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWASwitchSubsystem'),'Callback','privhdladvisor(''reloadAdvisor'')','Accel','CTRL+O');
                m_file.addMenuItem(T_openNewSubsystem);
                T_openNewSubsystem=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWAExportToScript'),'Callback','privhdladvisor(''exportToScript'')','Accel','CTRL+E');
                m_file.addMenuItem(T_openNewSubsystem);
                T_openNewSubsystem=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWAImportFromScript'),'Callback','privhdladvisor(''importFromScript'')','Accel','CTRL+I');
                m_file.addMenuItem(T_openNewSubsystem);
                m_file.addSeparator;

                this.MEMenus.loadSnapShot=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MALoadRestorePoint'),'Callback','ModelAdvisor.RestorePoint.openLoadDlg;','Accel','CTRL+SHIFT+O');
                this.MEMenus.saveSnapshot=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASaveAsRestorePoint'),'Callback','ModelAdvisor.RestorePoint.openSaveDlg;','Accel','CTRL+SHIFT+A');
                this.MEMenus.quicksaveSnapshot=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASaveRestorePoint'),'Callback','ModelAdvisor.RestorePoint.quickSave;','Accel','CTRL+SHIFT+S');
                m_file.addMenuItem(this.MEMenus.loadSnapShot);
                m_file.addMenuItem(this.MEMenus.saveSnapshot);
                m_file.addMenuItem(this.MEMenus.quicksaveSnapshot);
                m_file.addSeparator;
            end
            F_exit=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAExit'),'Callback','ModelAdvisor.Node.closeExplorer;');
            m_file.addMenuItem(F_exit);
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuFile)&&isfield(this.CustomObject.MenuFile,'Visible')&&~this.CustomObject.MenuFile.Visible

            else
                am.addSubMenu(me,m_file,DAStudio.message('Simulink:tools:MAFile'));
            end

            m_edit=am.createPopupMenu(me);
            this.MEMenus.Select=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASelect'),'Callback','ModelAdvisor.Node.select;');
            this.MEMenus.Deselect=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MADeselect'),'Callback','ModelAdvisor.Node.deselect;');
            this.MEMenus.Reset=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAReset'),'Callback','ModelAdvisor.Node.resetgui;');
            this.MEMenus.Find=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAFind'),'Callback','Simulink.ModelAdvisor.findCheck(''MA'',''down'');','Accel','CTRL+F');
            this.MEMenus.getCheckID=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:SendIDToWorkspace'),'Callback','Simulink.ModelAdvisor.getID;');
            this.MEMenus.getTaskID=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:SendInstanceIDToWorkspace'),'Callback','Simulink.ModelAdvisor.getCheckInstanceIDs(true);');

            m_edit.addMenuItem(this.MEMenus.Select);
            m_edit.addMenuItem(this.MEMenus.Deselect);
            m_edit.addMenuItem(this.MEMenus.Reset);
            m_edit.addSeparator;
            m_edit.addMenuItem(this.MEMenus.Find);
            m_edit.addMenuItem(this.MEMenus.getCheckID);
            m_edit.addMenuItem(this.MEMenus.getTaskID);
            am.addSubMenu(me,m_edit,DAStudio.message('Simulink:tools:MAEdit'));


            m_run=am.createPopupMenu(me);
            this.MEMenus.run=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MARun'),'Callback','ModelAdvisor.Node.run;');


            rootId=this.CustomTARootID;
            currentMenuLabel=modeladvisorprivate('getRunToFailureLabel',rootId);
            this.MEMenus.runToFail=am.createAction(me,'Text',currentMenuLabel,'Callback','ModelAdvisor.Node.runtofailure;');

            this.MEMenus.continue=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAContinue'),'Callback','ModelAdvisor.Node.continuerun;');

            m_run.addMenuItem(this.MEMenus.runToFail);
            m_run.addMenuItem(this.MEMenus.run);
            m_run.addMenuItem(this.MEMenus.continue);

            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuRun)&&isfield(this.CustomObject.MenuRun,'Visible')&&~this.CustomObject.MenuRun.Visible

            else
                am.addSubMenu(me,m_run,DAStudio.message('Simulink:tools:MARun'));
            end


            m_view=am.createPopupMenu(me);

            if strcmp(this.CustomTARootID,'_modeladvisor_')
                this.MEMenus.openConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MALoadConfiguration'),'Callback','ModelAdvisor.ConfigUI.openLoadDlg;');
                m_view.addMenuItem(this.MEMenus.openConfigUI);

                if Advisor.Utils.license('test','SL_Verification_Validation')
                    this.MEMenus.editConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAOpenConfigurationEditor'),'Callback','Simulink.ModelAdvisor.openConfigUIFromMAMenu;');
                    m_view.addMenuItem(this.MEMenus.editConfigUI);
                end
                if slfeature('ModelAdvisorConfigurationFile')
                    m_view.addSeparator;
                    this.MEMenus.m_setConfigUIforMdl=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:AssociateConfigToModel'),'Callback','modeladvisorprivate(''modeladvisorutil2'',''SetActiveConfigForModel'');');
                    m_view.addMenuItem(this.MEMenus.m_setConfigUIforMdl);
                    m_view.addSeparator;
                end
                this.MEMenus.m_setConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASetDefaultConfiguration'),'Callback','modeladvisorprivate(''modeladvisorutil2'',''SetActiveConfigAsPref'');');
                m_view.addMenuItem(this.MEMenus.m_setConfigUI);
                this.MEMenus.m_resetConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MARestoreDefaultConfiguration'),'Callback','ModelAdvisor.ConfigUI.openRestoreDlg;');
                m_view.addMenuItem(this.MEMenus.m_resetConfigUI);
                m_view.addSeparator;
            end

            if strcmp(this.CustomTARootID,'_SYSTEM_By Product_Simulink Code Inspector')||...
                exist(fullfile(matlabroot,'toolbox','slci','slci','+simulink','+internal','+customization','internalCustomizationSLCI.p'),'file')||...
                exist(fullfile(matlabroot,'toolbox','slci','slci','+simulink','+internal','+customization','internalCustomizationSLCI.m'),'file')
                if this.TreatAsMdlref
                    treatAsMdlrefValue='on';
                else
                    treatAsMdlrefValue='off';
                end
                s_treatasmdlref=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:TreatAsRefMdl'),'Callback','modeladvisorprivate(''modeladvisorutil2'',''ToggleTreatAsMdlref'')','toggleAction','on','on',treatAsMdlrefValue);
                m_view.addMenuItem(s_treatasmdlref);
                this.MEMenus.s_treatasmdlref=s_treatasmdlref;
                m_view.addSeparator;
            end

            M_popupOption=am.createAction(me,'Text',[DAStudio.message('ModelAdvisor:engine:Preferences'),'...'],'Callback','modeladvisorprivate(''modeladvisorutil2'',''PopupOptionDlg'')');
            m_view.addMenuItem(M_popupOption);
            this.MEMenus.M_popupOption=M_popupOption;
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuSettings)&&isfield(this.CustomObject.MenuSettings,'Visible')&&~this.CustomObject.MenuSettings.Visible

            else
                if~strcmp(this.TaskAdvisorRoot.ID,'com.mathworks.FPCA.FixedPointConversionTask')
                    am.addSubMenu(me,m_view,DAStudio.message('ModelAdvisor:engine:Settings'));
                end
            end

            this.ShowInformer=false;

            if(strcmp(this.TaskAdvisorRoot.ID,'SysRoot')||strcmp(this.TaskAdvisorRoot.ID,'CommandLineRun'))&&modeladvisorprivate('modeladvisorutil2','FeatureControl','SupportExclusions')
                m_exclusions=am.createPopupMenu(me);




                if exist('prefdir','file')
                    correctPrefdirUtil=false;
                else
                    correctPrefdirUtil=true;
                end

                ShowInformerGUI=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:MADashboardHighlight'),'Callback','ModelAdvisor.Node.toggleCheckResultOverlay(''GUI'');','toggleAction','on',...
                'icon',fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','overlay.png'));
                if correctPrefdirUtil
                    this.ShowInformer=getpref('modeladvisor','ShowInformer',this.ShowInformer);
                end
                if this.ShowInformer
                    ShowInformerGUI.on='on';
                    ShowInformerGUI.toolTip=DAStudio.message('ModelAdvisor:engine:MADisableHighlighting');
                else
                    ShowInformerGUI.on='off';
                    ShowInformerGUI.toolTip=DAStudio.message('ModelAdvisor:engine:MAEnableHighlighting');
                end
                m_exclusions.addMenuItem(ShowInformerGUI);
                this.MEMenus.ShowInformerGUI=ShowInformerGUI;

                ShowExclusionsGUI=am.createAction(me,'Text',[' ',DAStudio.message('ModelAdvisor:engine:HighliteExclusions')],'Callback','ModelAdvisor.Node.toggleCheckResultOverlay(''Exclusion'');','toggleAction','on',...
                'toolTip',DAStudio.message('ModelAdvisor:engine:HighliteExclusionsTooltip'));
                if correctPrefdirUtil
                    this.ShowExclusionsOnGUI=getpref('modeladvisor','ShowExclusionsOnGUI',this.ShowExclusionsOnGUI);
                end
                if this.ShowExclusionsOnGUI
                    ShowExclusionsGUI.on='on';
                else
                    ShowExclusionsGUI.on='off';
                end
                m_exclusions.addMenuItem(ShowExclusionsGUI);
                this.MEMenus.ShowExclusionsGUI=ShowExclusionsGUI;

                ShowCheckResultsGUI=am.createAction(me,'Text',[' ',DAStudio.message('ModelAdvisor:engine:HighliteResults')],'Callback','ModelAdvisor.Node.toggleCheckResultOverlay(''CheckResult'');','toggleAction','on',...
                'toolTip',DAStudio.message('ModelAdvisor:engine:HighliteResultsTooltip'));
                if correctPrefdirUtil
                    this.ShowCheckResultsOnGUI=getpref('modeladvisor','ShowCheckResultsOnGUI',this.ShowCheckResultsOnGUI);
                end
                if this.ShowCheckResultsOnGUI
                    ShowCheckResultsGUI.on='on';
                else
                    ShowCheckResultsGUI.on='off';
                end
                m_exclusions.addMenuItem(ShowCheckResultsGUI);
                this.MEMenus.ShowCheckResultsGUI=ShowCheckResultsGUI;

                am.addSubMenu(me,m_exclusions,DAStudio.message('ModelAdvisor:engine:Highlighting'));
            end


            m_help=am.createPopupMenu(me);
            sm1=[];
            H_mdladvhelp=[];
            H_mdladvabout=[];
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuHelp)&&isfield(this.CustomObject.MenuHelp,'Text')
                H_mdladvhelp=am.createAction(me,'Text',this.CustomObject.MenuHelp.Text,'Callback',this.CustomObject.MenuHelp.Callback);
            end
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuAbout)&&isfield(this.CustomObject.MenuAbout,'Text')
                H_mdladvabout=am.createAction(me,'Text',this.CustomObject.MenuAbout.Text,'Callback',this.CustomObject.MenuAbout.Callback);
            end
            if strncmp(this.TaskAdvisorRoot.ID,'com.mathworks.FPCA.',19)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('Simulink:tools:FPCAHelp'),'Callback','helpview([docroot,''/toolbox/fixedpoint/fixedpoint.map''],''fpa_help_button'');');
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('FixedPointTool:fixedPointTool:actionHELPABOUTSLFXPT'),'Callback','fxptui.aboutslfixpoint;');
            elseif strncmp(this.TaskAdvisorRoot.ID,'com.mathworks.HDL.ModelChecker',30)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLModelCheckerRootHelp'),'Callback','helpview([docroot,''/toolbox/hdlcoder/csh/hdlmodelchecker.map''],''hdlmodelchecker_help_button'');');
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWAAbout'),'Callback','privhdladvisor(''aboutslhdlcoder'');');
            elseif strncmp(this.TaskAdvisorRoot.ID,'com.mathworks.HDL.',18)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWARootHelp'),'Callback','helpview([docroot,''/toolbox/hdlcoder/csh/hdlwa.map''],''hdlwa_help_button'');');
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWAAbout'),'Callback','privhdladvisor(''aboutslhdlcoder'');');
            elseif strncmp(this.TaskAdvisorRoot.ID,'com.mathworks.cgo.group',23)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:CodeGenAdvisorHelp'),'Callback','helpview([docroot,''/toolbox/rtw/helptargets.map''],''scoder_code_gen_advisor'');');
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAAboutSimulink'),'Callback','daabout(''simulink'');');
            elseif strcmp(this.TaskAdvisorRoot.ID,UpgradeAdvisor.UPGRADE_GROUP_ID)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('SimulinkUpgradeAdvisor:advisor:upgradeAdvisorHelp'),'Callback','helpview(fullfile(docroot,''simulink'',''helptargets.map''),''upgrade_advisor'');');
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAAboutSimulink'),'Callback','daabout(''simulink'');');
            end
            if isempty(H_mdladvhelp)&&isempty(H_mdladvabout)
                H_mdladvhelpHDL=am.createAction(me,'Text',DAStudio.message('HDLShared:hdldialog:HDLWARootHelp'),'Callback','helpview([docroot,''/toolbox/hdlcoder/csh/hdlwa.map''],''hdlwa_help_button'');');
                H_mdladvhelpCGA=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:CodeGenAdvisorHelp'),'Callback','helpview([docroot,''/toolbox/rtw/helptargets.map''],''scoder_code_gen_advisor'');');
                H_mdladvhelpSLCI=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:SimulinkCodeInspectorHelp'),'Callback','helpview([docroot,''/toolbox/slci/helptargets.map''],''slci_advisor_help'');');
                H_mdladvOtherAdvisors=[H_mdladvhelpHDL,H_mdladvhelpCGA,H_mdladvhelpSLCI];
                sm1=am.createPopupMenu(me);
                for i=1:length(H_mdladvOtherAdvisors)
                    sm1.addMenuItem(H_mdladvOtherAdvisors(i));
                end
            end
            if isempty(H_mdladvhelp)
                H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAModelAdvisorHelp'),'Callback','modeladvisor(''help'');');
            end
            if isempty(H_mdladvabout)
                H_mdladvabout=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAAboutSimulink'),'Callback','daabout(''simulink'');');
            end
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuAbout)&&isfield(this.CustomObject.MenuAbout,'Visible')&&~this.CustomObject.MenuAbout.Visible

            else
                m_help.addMenuItem(H_mdladvhelp);
            end
            if~isempty(sm1)
                m_help.addSubMenu(sm1,DAStudio.message('ModelAdvisor:engine:SpecializedAdvisors'));
            end
            m_help.addSeparator;
            if~isempty(this.CustomObject)&&~isempty(this.CustomObject.MenuAbout)&&isfield(this.CustomObject.MenuAbout,'Visible')&&~this.CustomObject.MenuAbout.Visible

            else
                m_help.addMenuItem(H_mdladvabout);
            end
            am.addSubMenu(me,m_help,DAStudio.message('Simulink:tools:MAHelp'));

            if~isempty(me.UserData)



                me.UserData.toolbar.visible=false;
                me.UserData=[];
            end
            tb=am.createToolBar(me);
            modeladvisorprivate('modeladvisorutil2','createToolbar',me,am,tb,'MA',this);








