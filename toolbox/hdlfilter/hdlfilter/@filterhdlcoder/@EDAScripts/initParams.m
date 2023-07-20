function initParams(this,tbfilenames)




    this.TestBenchFilesList=tbfilenames;
    this.TopLevelName=hdlentitytop;
    this.TestBenchName=hdlgetparameter('tb_name');
    this.TargetLanguage=hdlgetparameter('target_language');
    this.IsVHDL=hdlgetparameter('isvhdl');
    this.CodeGenDirectory=hdlGetCodegendir;

    this.GenerateCompileDoFile=hdlgetparameter('hdlcompilescript');
    this.GenerateTBCompileDoFile=hdlgetparameter('hdlcompiletb');
    this.GenerateSimDoFile=hdlgetparameter('hdlsimscript');
    this.GenerateSimProjectFile=hdlgetparameter('hdlsimprojectscript');
    this.GenerateSynthesisFile=hdlgetparameter('hdlsynthscript');
    this.GenerateMapFile=hdlgetparameter('hdlmapfile');

    this.CompileDoFilePostFix=hdlgetparameter('hdlcompilefilepostfix');
    this.SimDoFilePostFix=hdlgetparameter('hdlsimfilepostfix');
    this.SimProjectFilePostFix=hdlgetparameter('hdlsimprojectfilepostfix');
    this.MapFilePostFix=hdlgetparameter('hdlmapfilepostfix');
    this.SynthesisFilePostFix=hdlgetparameter('hdlsynthfilepostfix');


    this.HdlCompileInit=hdlgetparameter('hdlcompileinit');
    this.HdlCompileVhdlCmd=hdlgetparameter('hdlcompilevhdlcmd');
    this.HdlCompileVerilogCmd=hdlgetparameter('hdlcompileverilogcmd');
    this.SimulatorFlags=hdlgetparameter('simulator_flags');
    this.HdlCompileTerm=hdlgetparameter('hdlcompileterm');
    this.HdlSimInit=hdlgetparameter('hdlsiminit');
    this.HdlSimCmd=hdlgetparameter('hdlsimcmd');
    this.HdlSimViewWaveCmd=hdlgetparameter('hdlsimviewwavecmd');
    this.HdlSimTerm=hdlgetparameter('hdlsimterm');
    this.HdlSimProjectInit=hdlgetparameter('hdlsimprojectinit');
    this.HdlSimProjectCmd=hdlgetparameter('hdlsimprojectcmd');
    this.HdlSimprojectTerm=hdlgetparameter('hdlsimprojectterm');
    this.HdlMapArrow=hdlgetparameter('hdlmaparrow');
    this.HdlSynthTool=hdlgetparameter('hdlsynthtool');
    this.HdlSynthInit=hdlgetparameter('hdlsynthinit');
    this.HdlSynthCmd=hdlgetparameter('hdlsynthcmd');
    this.HdlSynthTerm=hdlgetparameter('hdlsynthterm');


    this.ScriptGenSuccessful=false;









