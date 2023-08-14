function varargout=openConfigUI(varargin)






    if~Advisor.Utils.license('checkout','SL_Verification_Validation')
        DAStudio.error('Simulink:tools:MAMissVnVLicenseForMACE');
    end

    this=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

    am=Advisor.Manager.getInstance;
    mp=ModelAdvisor.Preferences;
    if mp.ModelAdvisorWebUI
        am.updateCacheIfNeeded('quickmode');
        if(nargin==1)&&strcmp(varargin{1},'initializeOnly')
        else
            closeMAWindow(this);
            t=ModelAdvisorWebUI.interface.MACEUI.getInstance;
            if t.isOpen
                t.bringToFront();
                DAStudio.error('ModelAdvisor:engine:MACEAlreadyOpen');
            else
                t.debugMode(mp.MACEWebUIDebugMode);
                if((nargin==1)&&strcmp(varargin{1},'edittimeview'))
                    t.startOnEdittimeView(true);
                else
                    t.startOnEdittimeView(false);
                end
                mp=ModelAdvisor.Preferences;
                t.browserMode(mp.BrowserMode);
                t.open;
                if ispc
                    t.setIcon(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','ma.ico'));
                else
                    t.setIcon(fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','private','task_passed.png'));
                end


                connector=ModelAdvisorWebUI.interface.connector(t.appID);
                connector.isMACELoaded();
                waitfor(connector,'isLoaded',1);
                t.isMACELoaded=true;
            end
        end
        return
    end


mlock
    persistent me;
    persistent melistener1;%#ok<PUSE>
    persistent melistener2;%#ok<PUSE>
    persistent melistener3;%#ok<PUSE>
    persistent mdllistener;%#ok<PUSE>

    MACE_MACB_sidebyside=true;


    existingApplications=am.ApplicationObjMap.values;
    for i=1:length(existingApplications)
        currentMAObj=existingApplications{i}.getRootMAObj;
        if isa(currentMAObj.ConfigUIWindow,'DAStudio.Explorer')&&~isa(this.ConfigUIWindow,'DAStudio.Explorer')
            DAStudio.error('ModelAdvisor:engine:MACEAlreadyOpen');
        end
    end


    if~isa(this,'Simulink.ModelAdvisor')||~ishandle(this.SystemHandle)

        dummyMdls={};
        while 1
            dummySystem=new_system('','model');
            if~exist(ModelAdvisor.getWorkDir(dummySystem),'dir')
                break
            else
                dummyMdls{end+1}=dummySystem;%#ok<AGROW> % track unused models for clean up
            end
        end
        for i=1:length(dummyMdls)
            close_system(dummyMdls{i});
        end

        this=Simulink.ModelAdvisor.getModelAdvisor(dummySystem,'new');

        appId=this.ApplicationID;
        appObj=Advisor.Manager.getApplication('Id',appId);

        appObj.mdlListenerOperation('DetachListener');







        modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorInfo',this);
        this.ConfigUIStandaloneMode=true;
    end


    if isempty(this.CheckLibrary)
        origDirty=this.ConfigUIDirty;

        am.loadAllCachedFcnHandle(this.CheckCellArray);
        am.copySlCustomizationData('LibTaskAdvisorCellArray',this);


        CheckLibrary=cell(1,length(this.LibTaskAdvisorCellArray));
        for i=1:length(this.LibTaskAdvisorCellArray)
            tempObj=this.LibTaskAdvisorCellArray{i};
            tempObj.MAObj=this;


            CheckLibrary{i}=ModelAdvisor.ConfigUI.createFromMANodeObj(tempObj);

            if isa(tempObj,'ModelAdvisor.Task')
                checkCell=this.CheckCellArray;

                if(tempObj.MACIndex>0)&&(tempObj.MACIndex<=length(checkCell))
                    CheckLibrary{i}.InputParameters=checkCell{tempObj.MACIndex}.InputParameters;
                    CallbackContext=checkCell{tempObj.MACIndex}.CallbackContext;

                    if~strcmp(CallbackContext,'None')
                        CheckLibrary{i}.DisplayLabelPrefix=DAStudio.message('Simulink:tools:PrefixForCompileCheck');
                    end
                    CheckLibrary{i}.InputParametersCallback=checkCell{tempObj.MACIndex}.InputParametersCallback;
                    CheckLibrary{i}.InputParametersLayoutGrid=checkCell{tempObj.MACIndex}.InputParametersLayoutGrid;
                end
            end

            CheckLibrary{i}.MAObj=this;
            CheckLibrary{i}.InLibrary=true;
            if CheckLibrary{i}.Published&&isempty(CheckLibrary{i}.ParentObj)
                CheckLibrary{i}.ParentObj=0;
            end
        end
        this.CheckLibrary=CheckLibrary;
        this.ConfigUIDirty=origDirty;
    end


    if this.NOBROWSER
        return
    end


    MAExplorecreated=false;
    if~isa(me,'DAStudio.Explorer')
        MAExplorecreated=true;
        me=DAStudio.Explorer(this.TaskAdvisorRoot,'Model Advisor',false);

        screenSize=get(0,'ScreenSize');
        height=screenSize(4);
        width=screenSize(3);
        x=floor(width/6);
        y=floor(height/6);
        if width>1280
            if MACE_MACB_sidebyside
                height=floor(height/1.33);
                width=floor(width/1.33);
            else
                height=floor(height/1.5);
                width=floor(width/1.5);
            end
        else
            height=floor(height*0.8);
            width=floor(width*0.8);
        end
        me.position=[x,y,width,height];
        if~isempty(this.MAExplorerPosition)
            me.position=this.MAExplorerPosition;
        end


        me.icon=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources','mace.png');
        me.delegateClose=true;

        melistener1=handle.listener(me,'MEPostClosed',{@MECallback});
        melistener2=handle.listener(me,'MEDelete',{@MECallback});

        melistener3=handle.listener(me,'METreeSelectionChanged',{@MECallback});
    end


    if isempty(this.ConfigUIRoot)

        speedcache=this.TaskAdvisorCellArray;
        ConfigUICellArray=cell(1,length(speedcache));
        for i=1:length(speedcache)
            ConfigUICellArray{i}=ModelAdvisor.ConfigUI.createFromMANodeObj(speedcache{i});

            if isa(speedcache{i},'ModelAdvisor.Task')
                checkCell=this.CheckCellArray;

                if(speedcache{i}.MACIndex>0)&&(speedcache{i}.MACIndex<=length(checkCell))
                    ConfigUICellArray{i}.InputParameters=modeladvisorprivate('modeladvisorutil2','DeepCopy',checkCell{speedcache{i}.MACIndex}.InputParameters);
                    CallbackContext=checkCell{speedcache{i}.MACIndex}.CallbackContext;

                    if~strcmp(CallbackContext,'None')
                        ConfigUICellArray{i}.DisplayLabelPrefix=DAStudio.message('Simulink:tools:PrefixForCompileCheck');
                    end
                    ConfigUICellArray{i}.InputParametersLayoutGrid=checkCell{speedcache{i}.MACIndex}.InputParametersLayoutGrid;
                    ConfigUICellArray{i}.InputParametersCallback=checkCell{speedcache{i}.MACIndex}.InputParametersCallback;
                end
            end
        end
        this.ConfigUIRoot=ModelAdvisor.ConfigUI.createFromMANodeObj(this.TaskAdvisorRoot);
        this.ConfigUIRoot.DisplayName=DAStudio.message('Simulink:tools:MACETitle');

        if~isempty(this.ConfigUIRoot.ChildrenObj)
            for j=1:length(this.ConfigUIRoot.ChildrenObj)
                this.ConfigUIRoot.ChildrenObj{j}=ConfigUICellArray{this.ConfigUIRoot.ChildrenObj{j}};
            end
        end

        for i=1:length(ConfigUICellArray)



            if isnumeric(ConfigUICellArray{i}.ParentObj)
                if ConfigUICellArray{i}.ParentObj==0
                    ConfigUICellArray{i}.ParentObj=this.ConfigUIRoot;
                else
                    ConfigUICellArray{i}.ParentObj=ConfigUICellArray{ConfigUICellArray{i}.ParentObj};
                end

                ConfigUICellArray{i}.ParentObj.addChildren(ConfigUICellArray{i});
            end

            if~isempty(ConfigUICellArray{i}.ChildrenObj)
                for j=1:length(ConfigUICellArray{i}.ChildrenObj)
                    ConfigUICellArray{i}.ChildrenObj{j}=ConfigUICellArray{ConfigUICellArray{i}.ChildrenObj{j}};
                end
            end
            ConfigUICellArray{i}.Index=i;
        end
        this.ConfigUICellArray=ConfigUICellArray;
        this.ConfigUIDirty=false;
        ModelAdvisor.ConfigUI.stackoperation('init');
    end





    drawnow;
    me.setRoot(this.ConfigUIRoot);

    if MAExplorecreated
        createMenuToolbar(this,me);

        mdlObj=get_param(bdroot(this.System),'Object');
        if~this.ConfigUIStandaloneMode
            mdllistener=Simulink.listener(mdlObj,'CloseEvent',@LocalCloseCB);
        end
        this.ConfigUIWindow=me;
    end
    modeladvisorprivate('modeladvisorutil2','UpdateConfigUIWindowTitle',this);
    modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',me);

    me.showListView(false);
    closeMAWindow(this);
    me.show;



    if MACE_MACB_sidebyside&&MAExplorecreated
        ModelAdvisor.ConfigUI.librarybrowser;
        me.position=[floor(x-50),y,floor(width/2+100),height];
        this.CheckLibraryBrowser.position=[floor(x+width/2+50),y,floor(width/2-50),height];
        me.show;
    end

    if nargout==1
        varargout{1}=me;
    end

    if((nargin==1)&&strcmp(varargin{1},'edittimeview'))
        if~isempty(this.Toolbar)&&~isempty(this.Toolbar.viewComboBoxWidget)
            this.Toolbar.viewComboBoxWidget.selectItem(1);
        end
    end

    attic('add',this.ConfigUIRoot,this.CheckLibraryRoot);

    function closeMAWindow(this)
        if isa(this,'Simulink.ModelAdvisor')

            if isa(this.MAExplorer,'DAStudio.Explorer')

                modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorInfo',this);
                if isa(this.ResultGUI,'DAStudio.Informer')
                    slprivate('remove_hilite',bdroot(this.System));
                    this.ResultGUI.delete;
                end
                this.MAExplorer.hide;
            end
            if~isempty(this.AdvisorWindow)&&isa(this.AdvisorWindow,'Advisor.AdvisorWindow')
                this.AdvisorWindow.close();
            end
        end


        function attic(method,varargin)
            persistent data;%#ok<PUSE>
            switch(method)
            case 'add'
                data{1}=varargin{1};
                data{2}=varargin{2};
            case 'remove'
                data={};
            end










            function MECallback(this,event)
                switch(event.type)
                case 'MEDelete'
                    mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);


                    userCancel=modeladvisorprivate('modeladvisorutil2','PromptConfigurationSaveDialogIfDirty',mdladvObj);
                    if userCancel
                        return;
                    end



                    ModelAdvisor.ImportBlkTypeDialog.deleteInstance();


                    appId=mdladvObj.ApplicationID;
                    appObj=Advisor.Manager.getApplication('Id',appId);

                    appObj.delete();

                    this.delete;

                    attic('remove');


                case 'MEPostClosed'
                    mdladvObj=modeladvisorprivate('modeladvisorutil2','getMAObjFromDAExplorer',this);

                    userCancel=modeladvisorprivate('modeladvisorutil2','PromptConfigurationSaveDialogIfDirty',mdladvObj);
                    if userCancel
                        return;
                    else
                        mdladvObj.ConfigUIDirty=false;
                    end









                    if mdladvObj.ConfigUIStandaloneMode
                        mdladvObj.ConfigUIStandaloneMode=false;
                        if ishandle(mdladvObj.SystemHandle)
                            close_system(mdladvObj.Systemhandle);
                        end
                    end



                    rootNode=Advisor.Utils.convertMCOS(this.getRoot);
                    rootNode.closeExplorer;

                case 'METreeSelectionChanged'
                    modeladvisorprivate('modeladvisorutil2','UpdateConfigUIMenuToolbar',this);
                otherwise
                    DAStudio.error('Simulink:tools:MAUnknownEventReceived');
                end


                function LocalCloseCB(eventSrc,eventData)%#ok<INUSD>
                    ModelAdvisor.ConfigUI.closeExplorer;

                    function createMenuToolbar(this,me)
                        am=DAStudio.ActionManager;
                        am.initializeClient(me);
                        iconpath=fullfile(matlabroot,'toolbox','simulink','simulink','modeladvisor','resources');


                        tb=am.createToolBar(me);

                        F_new=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MANew'),'Icon',fullfile(iconpath,'file_new.png'),'Callback','ModelAdvisor.ConfigUI.newgui;','toolTip',DAStudio.message('ModelAdvisor:engine:MACENewMsg'),'Accel','CTRL+N');
                        tb.addAction(F_new);
                        F_open=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAOpen'),'Icon',fullfile(iconpath,'file_open.png'),'Callback','ModelAdvisor.ConfigUI.openLoadDlg;','toolTip',DAStudio.message('Simulink:tools:MACELoadMsg'),'Accel','CTRL+O');
                        tb.addAction(F_open);
                        F_save=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASave'),'Icon',fullfile(iconpath,'file_save.png'),'Callback','ModelAdvisor.ConfigUI.openSaveDlg;','toolTip',DAStudio.message('Simulink:tools:MACESaveMsg'),'Accel','CTRL+S');
                        tb.addAction(F_save);
                        tb.addSeparator;
                        E_undo=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAUndo'),'Icon',fullfile(iconpath,'edit_undo.png'),'Callback','ModelAdvisor.ConfigUI.stackoperation(''pop'');','Accel','CTRL+Z');
                        this.MEMenus.ConfigE_undo=E_undo;
                        tb.addAction(E_undo);
                        E_redo=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MARedo'),'Icon',fullfile(iconpath,'edit_redo.png'),'Callback','ModelAdvisor.ConfigUI.stackoperation(''redo'');','Accel','CTRL+Y');
                        this.MEMenus.ConfigE_redo=E_redo;
                        tb.addAction(E_redo);
                        tb.addSeparator;
                        F_cut=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MACut'),'Icon',fullfile(iconpath,'cut.png'),'Callback','ModelAdvisor.ConfigUI.cutgui;','Accel','CTRL+X','toolTip',DAStudio.message('Simulink:tools:MACECutMsg'));
                        this.MEMenus.ConfigF_cut=F_cut;
                        tb.addAction(F_cut);
                        F_copy=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MACopy'),'Icon',fullfile(iconpath,'copy.png'),'Callback','ModelAdvisor.ConfigUI.copygui;','Accel','CTRL+C','toolTip',DAStudio.message('Simulink:tools:MACECopyMsg'));
                        this.MEMenus.ConfigF_copy=F_copy;
                        tb.addAction(F_copy);
                        F_paste=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAPaste'),'Icon',fullfile(iconpath,'paste.png'),'Callback','ModelAdvisor.ConfigUI.pastegui;','Accel','CTRL+V','toolTip',DAStudio.message('Simulink:tools:MACEPasteMsg'));
                        this.MEMenus.ConfigF_paste=F_paste;
                        tb.addAction(F_paste);
                        F_delete=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MADelete'),'Icon',fullfile(iconpath,'delete.png'),'Callback','ModelAdvisor.ConfigUI.deletegui;','Accel','DELETE','toolTip',DAStudio.message('Simulink:tools:MACEDeleteMsg'));
                        this.MEMenus.ConfigF_delete=F_delete;
                        tb.addAction(F_delete);
                        tb.addSeparator;

                        F_moveup=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAMoveup'),'Icon',fullfile(iconpath,'arrow_move_up.png'),'Callback','ModelAdvisor.ConfigUI.moveup;','toolTip',DAStudio.message('Simulink:tools:MACEMoveUpMsg'));
                        this.MEMenus.ConfigF_moveup=F_moveup;
                        tb.addAction(F_moveup);
                        F_movedown=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAMovedown'),'Icon',fullfile(iconpath,'arrow_move_down.png'),'Callback','ModelAdvisor.ConfigUI.movedown;','toolTip',DAStudio.message('Simulink:tools:MACEMoveDownMsg'));
                        this.MEMenus.ConfigF_movedown=F_movedown;
                        tb.addAction(F_movedown);
                        tb.addSeparator;
                        F_newfolder=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MANewfolder'),'Icon',fullfile(iconpath,'folder_new.png'),'Callback','ModelAdvisor.ConfigUI.newfolder;','toolTip',DAStudio.message('Simulink:tools:MACEFolderNewMsg'));
                        this.MEMenus.ConfigF_newfolder=F_newfolder;
                        tb.addAction(F_newfolder);
                        tb.addSeparator;
                        F_checklibrary=am.createAction(me,'Text',DAStudio.message('ModelAdvisor:engine:MACB'),'Icon',fullfile(iconpath,'check_browser.png'),'Callback','ModelAdvisor.ConfigUI.librarybrowser;','toolTip',DAStudio.message('Simulink:tools:MACECheckBrowserMsg'));
                        tb.addAction(F_checklibrary);
                        tb.addSeparator;


                        m_file=am.createPopupMenu(me);
                        m_file.addMenuItem(F_new);
                        m_file.addMenuItem(F_open);
                        m_file.addMenuItem(F_save);
                        F_saveas=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASaveAs'),'Callback','ModelAdvisor.ConfigUI.openSaveAsDlg;');
                        m_file.addMenuItem(F_saveas);
                        m_file.addSeparator;
                        m_setConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MASetDefaultConfiguration'),'Callback','modeladvisorprivate(''modeladvisorutil2'',''SetActiveConfigAsPref'');');
                        this.MEMenus.Configm_setConfigUI=m_setConfigUI;
                        m_file.addMenuItem(m_setConfigUI);
                        m_resetConfigUI=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MARestoreDefaultConfiguration'),'Callback','ModelAdvisor.ConfigUI.openRestoreDlg;');
                        this.MEMenus.Configm_resetConfigUI=m_resetConfigUI;
                        m_file.addMenuItem(m_resetConfigUI);
                        m_file.addSeparator;
                        F_exit=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAExit'),'Callback','ModelAdvisor.ConfigUI.closeExplorer;');
                        m_file.addMenuItem(F_exit);
                        am.addSubMenu(me,m_file,DAStudio.message('Simulink:tools:MAFile'));

                        m_edit=am.createPopupMenu(me);
                        m_edit.addMenuItem(E_undo);
                        m_edit.addMenuItem(E_redo);
                        m_edit.addSeparator;
                        m_edit.addMenuItem(F_cut);
                        m_edit.addMenuItem(F_copy);
                        m_edit.addMenuItem(F_paste);
                        m_edit.addMenuItem(F_delete);
                        E_enable=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAEnable'),'Callback','ModelAdvisor.ConfigUI.enablegui;','toolTip',DAStudio.message('Simulink:tools:MACEEnableMsg'));
                        this.MEMenus.ConfigE_enable=E_enable;
                        m_edit.addMenuItem(E_enable);
                        E_disable=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MADisable'),'Callback','ModelAdvisor.ConfigUI.disablegui;','toolTip',DAStudio.message('Simulink:tools:MACEDisableMsg'));
                        this.MEMenus.ConfigE_disable=E_disable;
                        m_edit.addMenuItem(E_disable);
                        m_edit.addSeparator;
                        m_edit.addMenuItem(F_newfolder);
                        m_edit.addSeparator;
                        m_edit.addMenuItem(F_moveup);
                        m_edit.addMenuItem(F_movedown);
                        am.addSubMenu(me,m_edit,DAStudio.message('Simulink:tools:MAEdit'));

                        m_view=am.createPopupMenu(me);
                        m_view.addMenuItem(F_checklibrary);
                        am.addSubMenu(me,m_view,DAStudio.message('Simulink:tools:MAView'));

                        m_help=am.createPopupMenu(me);
                        H_mdladvhelp=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAModelAdvisorHelp'),'Callback','modeladvisor(''help'');');
                        H_mdladvabout=am.createAction(me,'Text',DAStudio.message('Simulink:tools:MAAboutSimulink'),'Callback','daabout(''simulink'');');
                        m_help.addMenuItem(H_mdladvhelp);
                        m_help.addSeparator;
                        m_help.addMenuItem(H_mdladvabout);
                        am.addSubMenu(me,m_help,DAStudio.message('Simulink:tools:MAHelp'));

                        if isempty(me.UserData)
                            modeladvisorprivate('modeladvisorutil2','createToolbar',me,am,tb,'MACE');
                        end
