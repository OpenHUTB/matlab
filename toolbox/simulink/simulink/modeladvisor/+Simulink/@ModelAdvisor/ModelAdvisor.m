classdef(CaseInsensitiveProperties=true)ModelAdvisor<handle














    events(Hidden)
CheckExecutionStart
    end




    properties

        SessionDataHasBeenSaved=false;


        AtticData={};


        CheckCellArray={};


        FastCheckAccessTable=[];


        CheckIDMap=[];


        CheckIDToTaskMap=[];


        TaskCellArray={};


        TaskAdvisorCellArray={};


        LibTaskAdvisorCellArray={};


        UserData={};


        TreatAsMdlref=false;


        ExclusionCellArray={};


        TaskAdvisorRoot={};


        DialogCellArray={};


        ConfigUICellArray={};


        ConfigUIRoot={};


        ConfigUIStandaloneMode=false;


        ConfigFilePath='';


        ConfigFileOptions={};


        StartConfigFilePath='';


        APIConfigFilePath='';


        PreferenceConfigFilePath='';


        CustomTARootID='';


        CustomObject={};

        NOBROWSER=false;


        ContinueViewExistRpt=false;

        hasLoadedExistingData=false;


        ShowWarnDialog=true;


        ShowProgressbar=true;


        ShowSourceTab=false;


        ShowExclusionTab=true;


        ShowExclusions=true;


        ShowByProduct=false;


        ShowByTask=true;





        ShowInformer=false;


        ShowExclusionsOnGUI=true;


        ShowCheckResultsOnGUI=true;


        ProjectResultMapData={};


        ResultMap={};


        ResultGUI={};


        ResetAfterAction=true;


        ShowActionResultInRpt=false;


        CmdLine=false;


        Database={};


        MEMenus={};


        Toolbar={};


        BrowserWindow={};


        MAExplorer={};


        ConfigUIWindow={};


        CheckLibraryBrowser={};


        ConfigUICopyObj={};


        CheckLibrary={};


        CheckLibraryRoot={};


        MAExplorerPosition={};


        ListExplorer={};


        RPObj={};


        RPDialog={};


        R2FMode=false;


        R2FStart={};


        R2FStop={};


        Breakpoint={};


        LatestRunID='';




        HasCompiled=false;




        HasCompiledForCodegen=false;




        HasCGIRed=false;




        HasSLDVCompiled=false;



        recordCoverageFlag='';


        Waitbar={};


        UserCancel=false;


        GlobalTimeOut=false;



        NeedTermination=true;

        NormalModeConfiguration=[];


        EngineInterfaceFeature={};


        BaselineMode=false;


        StartInTaskPage=false;


        ActiveCheck={};


        ActiveCheckID=0;


        Stage='';


        ErrorLog={};


        RunTime=0;



        StartTime=0;


        System={};


        SystemHandle={};


        SystemName='';

        URL='';


        ApplicationID='';


        ComponentID='';


        IsLibrary=false;


        parallel=false;


        runInBackground=false;


        isSleeping=false;


        EmitInputParametersToReport=true;


        viewMode='MAStandardUI';


        advertisements={};


        Status='';


        listener={};

        AdvisorWindow=[];
    end


    properties

        ConfigUIDirty=false;
    end




    properties(SetAccess=private)
        ModelName='';
    end




    properties(Hidden=true)

        TaskManager={};


        MultiMode=false;


        EdittimeViewMode=false;

        isUserLoaded=false;


        ConfigUIJSON='';


        SLDVData=[];
    end




    methods
        function this=ModelAdvisor

            mlock;


            this.initSchemaData;
        end
        deleteObj(this);






    end




    methods(Access=private)
        lookForDeprecatedChecks(this,bCheckConfig);
    end




    methods(Hidden=true)
        displayInformer(this);
        closeInformer(this);
        focusInformerNode(this,nodeObj);
    end




    methods(Static=true)

        mdladvObj=getModelAdvisor(system,varargin);

        output=reportExists(SystemName);

        activeObj=getActiveModelAdvisorObj(varargin);

        activeObj=getFocusModelAdvisorObj(varargin);

        varargout=openConfigUI(varargin);

        varargout=openConfigUIFromMAMenu(varargin);

        findCheck(varargin);
        runInBackgroundCB(sys);

        checkIDList=getID(varargin);

        taskIDList=getCheckInstanceIDs(varargin);

        closeToolBar(varargin);

        checkEnvironment(subsys);

        errmsg=getErrorMessage(E);
    end




    methods
        function set.ConfigUIDirty(this,valueProposed)


            this.ConfigUIDirty=valueProposed;
            if isa(this.ConfigUIWindow,'DAStudio.Explorer')
                if valueProposed
                    if length(this.ConfigUIWindow.Title)>1&&~strcmp(this.ConfigUIWindow.Title(end-1:end),' *')
                        this.ConfigUIWindow.Title=[this.ConfigUIWindow.Title,' *'];
                    end
                elseif~valueProposed
                    if length(this.ConfigUIWindow.Title)>1&&strcmp(this.ConfigUIWindow.Title(end-1:end),' *')
                        this.ConfigUIWindow.Title=this.ConfigUIWindow.Title(1:end-2);
                    end
                end
            end
        end









        function modelName=get.ModelName(this)
            modelName=this.getFullName();

            if isempty(modelName)&&~isempty(this.SystemName)









                try
                    modelName=bdroot(this.SystemName);
                catch
                    modelName='';
                end
            end
        end

        function set.HasCompiledForCodegen(obj,value)
            if slfeature('UpdateDiagramForCodegen')>0
                obj.HasCompiledForCodegen=value;
            end
        end
    end

end


