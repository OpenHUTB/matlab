function initParams(this,entityNameList,entityPathList,TBFilesList,varargin)













    this.EntityNamelist=entityNameList;
    this.EntityPathList=entityPathList;
    this.TestBenchFilesList=TBFilesList;

    if nargin>8
        this.GenerateTargetCodegenFile=varargin{5};
    else
        this.GenerateTargetCodegenFile=false;
    end

    if nargin>7

        this.SubModelData=varargin{4};
    else
        this.SubModelData={};
    end

    if nargin>6

        this.CodeGenDirectory=varargin{3};
    else
        this.CodeGenDirectory=hdlGetCodegendir;
    end

    if nargin>5
        this.IsTopModel=varargin{2};
    else
        this.IsTopModel=true;
    end

    if nargin>4

        this.TopLevelName=varargin{1};
    else
        this.TopLevelName=hdlentitytop;
    end


    this.SimulationTool=hdlgetparameter('simulationtool');


    this.VerilogLibraryName='work';
    this.VhdlLibraryName=hdlgetparameter('vhdl_library_name');

    this.TestBenchName=hdlgetparameter('tb_name');
    this.TargetLanguage=hdlgetparameter('target_language');

    this.GenerateCompileDoFile=hdlgetparameter('hdlcompilescript');
    this.GenerateTBCompileDoFile=hdlgetparameter('hdlcompiletb');
    this.GenerateSimDoFile=hdlgetparameter('hdlsimscript');
    this.GenerateSimProjectFile=hdlgetparameter('hdlsimprojectscript');
    this.GenerateSynthesisFile=hdlgetparameter('hdlsynthscript');
    this.GenerateMapFile=hdlgetparameter('hdlmapfile');

    this.HDLCodeCoverage=hdlgetparameter('hdlcodecoverage');


    n_InitializeScriptCmds();

    this.MapFilePostFix=hdlgetparameter('hdlmapfilepostfix');
    this.SynthesisFilePostFix=hdlgetparameter('hdlsynthfilepostfix');

    this.HdlSimProjectInit=hdlgetparameter('hdlsimprojectinit');
    this.HdlSimProjectCmd=hdlgetparameter('hdlsimprojectcmd');
    this.HdlSimProjectTerm=hdlgetparameter('hdlsimprojectterm');
    this.HdlMapArrow=hdlgetparameter('hdlmaparrow');
    this.HdlSynthTool=hdlgetparameter('hdlsynthtool');
    this.HdlSynthInit=hdlgetparameter('hdlsynthinit');
    this.HdlSynthCmd=hdlgetparameter('hdlsynthcmd');
    this.HdlSynthTerm=hdlgetparameter('hdlsynthterm');
    this.HdlSynthLibCmd=hdlgetparameter('hdlsynthlibcmd');
    this.HdlSynthLibSpec=hdlgetparameter('hdlsynthlibspec');
    this.InitialValuesDoFile='set_initial_values.do';


    function n_InitializeScriptCmds()

        this.CompileDoFilePostFix=hdlgetparameter('hdlcompilefilepostfix');
        this.SimDoFilePostFix=hdlgetparameter('hdlsimfilepostfix');
        this.SimProjectFilePostFix=hdlgetparameter('hdlsimprojectfilepostfix');
        this.HdlCompileInit=hdlgetparameter('hdlcompileinit');
        this.HdlCompileVhdlCmd=hdlgetparameter('hdlcompilevhdlcmd');
        this.HdlCompileVerilogCmd=hdlgetparameter('hdlcompileverilogcmd');
        this.SimulatorFlags=hdlgetparameter('simulator_flags');
        this.HdlCompileTerm=hdlgetparameter('hdlcompileterm');

        this.HdlElaborationCmd=hdlgetparameter('hdlelaborationcmd');

        this.HdlCodeCoverageCompilationFlag=hdlgetparameter('hdlcodecoveragecompilationflag');

        this.HdlCodeCoverageElaborationFlag=hdlgetparameter('hdlcodecoverageelaborationflag');

        this.HdlCodeCoverageSimulationFlag=hdlgetparameter('hdlcodecoveragesimulationflag');

        this.HdlCodeCoverageReportGen=hdlgetparameter('hdlcodecoveragereportgen');


        this.HdlSimInit=hdlgetparameter('hdlsiminit');

        this.HdlSimViewWaveSetupCmd=hdlgetparameter('hdlsimviewwavesetupcmd');
        this.HdlSimCmd=hdlgetparameter('hdlsimcmd');
        this.HdlSimViewWaveCmd=hdlgetparameter('hdlsimviewwavecmd');
        this.HdlSimTerm=hdlgetparameter('hdlsimterm');
    end
end


