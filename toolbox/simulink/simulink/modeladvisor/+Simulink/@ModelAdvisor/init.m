function success=init(this,system)




    if nargin>1
        system=convertStringsToChars(system);
    end

    PerfTools.Tracer.logMATLABData('MAGroup','Init MA',true);

    this.stage='init';


    mp=ModelAdvisor.Preferences;
    this.ShowProgressbar=mp.ShowProgressbar;


    load_system(getfullname(system));
    try
        cleanup(this);
        this.IsLibrary=isLibraryOrSubsystem(system);

        this.System=system;
        this.SystemHandle=get_param(this.System,'handle');
        this.SystemName=getfullname(this.System);

        this.updateExclusion;

        am=Advisor.Manager.getInstance();
        displayProgressBar(this);
        needLoad=checkIfNeedLoadSlprj(this);
        if needLoad

            this.initData(true);
        else
            this.initData(false);
        end

        if~isempty(am.Progressbar)&&ishandle(am.Progressbar)
            close(am.Progressbar);
            am.Progressbar=[];
        end

        ModelAdvisor.ClearExclusions;
        setRunInBackground(this);
        success=true;
    catch E

        if~isempty(am.Progressbar)&&ishandle(am.Progressbar)
            close(am.Progressbar);
            am.Progressbar=[];
        end




        if strcmp(E.identifier,'RTW:buildProcess:buildDirInMatlabDir')
            DAStudio.error('ModelAdvisor:engine:MAEnvironmentErrMsg',E.message);
        elseif strcmp(E.identifier,'SLDD:sldd:DictFuncThrewStdException')&&...
            contains(E.message,DAStudio.message('SLDD:sldd:FailedToCreateCache',''))
            DAStudio.error('ModelAdvisor:engine:ExceedsPathLength')
        else
            rethrow(E);
        end
    end
    PerfTools.Tracer.logMATLABData('MAGroup','Init MA',false);
end




function output=isLibraryOrSubsystem(system)
    system=bdroot(system);
    fp=get_param(system,'ObjectParameters');
    if isfield(fp,'BlockDiagramType')
        if any(strcmpi(get_param(system,'BlockDiagramType'),{'library','subsystem'}))
            output=1;
        else
            output=0;
        end
    else

        output=1;
    end
end

function cleanup(this)

    this.AtticData={};
    this.CheckCellArray={};
    this.ShowSourceTab=false;
    this.ShowExclusionTab=false;
    this.R2FMode=false;
    this.R2FStart={};
    this.R2FStop={};
    this.CustomObject={};
end

function displayProgressBar(this)
    am=Advisor.Manager.getInstance();

    cmdLineRun=this.CmdLine;

    if~cmdLineRun&&this.ShowProgressbar


        if isfield(this.AtticData,'Progressbar')&&~isempty(this.AtticData.Progressbar)
            close(this.AtticData.Progressbar);
            this.AtticData.Progressbar=[];
        end

        Progressbar=waitbar(0.2,DAStudio.message('Simulink:tools:MAInitializing'),'Name',DAStudio.message('Simulink:tools:MAPleaseWait'));
        am.Progressbar=Progressbar;
    end
end

function needLoad=checkIfNeedLoadSlprj(this)

    MADatabase=[this.getWorkDir('CheckOnly'),filesep,'ModelAdvisorData'];
    dataExist=exist(MADatabase,'file');

    PerfTools.Tracer.logMATLABData('MAGroup','Create Working Directory',true);
    this.AtticData.WorkDir=this.getWorkDir;
    PerfTools.Tracer.logMATLABData('MAGroup','Create Working Directory',false);
    this.AtticData.DiagnoseRightFrame=[this.AtticData.WorkDir,filesep,'report.html'];



    isLoadPageFromMA=(dataExist||this.parallel)...
    &&~strcmp(this.CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask');
    isLoadPageFromFPASnapshot=exist(this.AtticData.DiagnoseRightFrame,'file')...
    &&strcmp(this.CustomTARootID,'com.mathworks.FPCA.FixedPointConversionTask')...
    &&fpcadvisorprivate('fpcaattic','AtticData','isRestorePointLoad');
    if isLoadPageFromMA||isLoadPageFromFPASnapshot
        if rtwprivate('cmpTimeFlag',MADatabase,which(getfullname(bdroot(this.SystemName))))>0

            if this.ShowWarnDialog
                if~this.CmdLine&&desktop('-inuse')
                    warndlgHandle=warndlg(DAStudio.message('Simulink:tools:MAMdlNewerThanRpt',getfullname(bdroot(this.SystemName))));
                    set(warndlgHandle,'Tag','MAMdlNewerThanRpt');
                end
            end
        end
        needLoad=true;
    else
        needLoad=false;
    end
end

function setRunInBackground(this)

    if strcmp(this.CustomTARootID,'_modeladvisor_')&&~this.parallel
        mp=ModelAdvisor.Preferences;
        this.runInBackground=mp.RunInBackground;
    else
        this.runInBackground=false;
    end
end