classdef EDAScriptsBase<matlab.mixin.SetGet&matlab.mixin.Copyable





































































    properties(SetObservable,GetObservable)

        TopLevelName='';

        TestBenchName='';

        TestBenchFilesList=cell(0,1);

        EntityPathList=cell(0,1);

        EntityNamelist=cell(0,1);

        SubModelData=[];

        TargetLanguage='';

        HDLCodeCoverage=false;

        SimulationTool='';

        CodeGenDirectory='';

        IsTopModel=false;

        GenerateCompileDoFile=false;

        GenerateTBCompileDoFile=false;

        GenerateSimDoFile=false;

        GenerateSimProjectFile=false;

        GenerateSynthesisFile=false;

        GenerateMapFile=false;

        GenerateTargetCodegenFile=false;

        CompileDoFilePostFix='';

        SimDoFilePostFix='';

        SimProjectFilePostFix='';

        SynthesisFilePostFix='';

        MapFilePostFix='';

        HdlCompileInit='';

        HdlCompileVhdlCmd='';

        HdlCompileVerilogCmd='';

        HdlElaborationCmd='';

        HdlElaborationFlags='';

        SimulatorFlags='';

        VerilogLibraryName='';

        VhdlLibraryName='';

        HdlCodeCoverageCompilationFlag='';

        HdlCodeCoverageElaborationFlag='';

        HdlCodeCoverageSimulationFlag='';

        HdlCodeCoverageReportGen='';

        HdlCompileTerm='';

        HdlSimInit='';

        HdlSimCmd='';

        HdlSimViewWaveSetupCmd='';

        HdlSimViewWavePrefix='';

        HdlSimViewWaveRefPrefix='';

        HdlSimViewWaveCmd='';

        HdlSimTerm='';

        HdlSimProjectInit='';

        HdlSimProjectCmd='';

        HdlSimProjectTerm='';

        HdlSynthTool='';

        HdlSynthInit='';

        HdlSynthCmd='';

        HdlMapArrow='';

        HdlSynthTerm='';

        HdlSynthLibCmd='';

        HdlSynthLibSpec='';

        InitialValuesDoFile='';
    end


    methods
        function this=EDAScriptsBase(entityNameList,entityPathList,TBFilesList,varargin)
            this.initParams(entityNameList,entityPathList,TBFilesList,varargin{:});
        end

    end

    methods
        function set.TopLevelName(obj,value)


            obj.TopLevelName=value;
        end

        function set.TestBenchName(obj,value)


            obj.TestBenchName=value;
        end

        function set.TestBenchFilesList(obj,value)


            obj.TestBenchFilesList=value;
        end

        function set.EntityPathList(obj,value)


            obj.EntityPathList=value;
        end

        function set.EntityNamelist(obj,value)


            obj.EntityNamelist=value;
        end

        function set.TargetLanguage(obj,value)

            validateattributes(value,{'char'},{'row'},'','TargetLanguage')
            obj.TargetLanguage=value;
        end

        function set.HDLCodeCoverage(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','HDLCodeCoverage')
            value=logical(value);
            obj.HDLCodeCoverage=value;
        end

        function set.SimulationTool(obj,value)


            obj.SimulationTool=value;
        end

        function set.CodeGenDirectory(obj,value)


            obj.CodeGenDirectory=value;
        end

        function set.IsTopModel(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','IsTopModel')
            value=logical(value);
            obj.IsTopModel=value;
        end

        function set.GenerateCompileDoFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateCompileDoFile')
            value=logical(value);
            obj.GenerateCompileDoFile=value;
        end

        function set.GenerateTBCompileDoFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateTBCompileDoFile')
            value=logical(value);
            obj.GenerateTBCompileDoFile=value;
        end

        function set.GenerateSimDoFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateSimDoFile')
            value=logical(value);
            obj.GenerateSimDoFile=value;
        end

        function set.GenerateSimProjectFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateSimProjectFile')
            value=logical(value);
            obj.GenerateSimProjectFile=value;
        end

        function set.GenerateSynthesisFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateSynthesisFile')
            value=logical(value);
            obj.GenerateSynthesisFile=value;
        end

        function set.GenerateMapFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateMapFile')
            value=logical(value);
            obj.GenerateMapFile=value;
        end

        function set.GenerateTargetCodegenFile(obj,value)

            validateattributes(value,{'numeric','logical'},{'scalar','nonnan'},'','GenerateTargetCodegenFile')
            value=logical(value);
            obj.GenerateTargetCodegenFile=value;
        end

        function set.CompileDoFilePostFix(obj,value)


            obj.CompileDoFilePostFix=value;
        end

        function set.SimDoFilePostFix(obj,value)


            obj.SimDoFilePostFix=value;
        end

        function set.SimProjectFilePostFix(obj,value)


            obj.SimProjectFilePostFix=value;
        end

        function set.SynthesisFilePostFix(obj,value)


            obj.SynthesisFilePostFix=value;
        end

        function set.MapFilePostFix(obj,value)


            obj.MapFilePostFix=value;
        end

        function set.HdlCompileInit(obj,value)


            obj.HdlCompileInit=value;
        end

        function set.HdlCompileVhdlCmd(obj,value)


            obj.HdlCompileVhdlCmd=value;
        end

        function set.HdlCompileVerilogCmd(obj,value)


            obj.HdlCompileVerilogCmd=value;
        end

        function set.HdlElaborationCmd(obj,value)


            obj.HdlElaborationCmd=value;
        end

        function set.HdlElaborationFlags(obj,value)


            obj.HdlElaborationFlags=value;
        end

        function set.SimulatorFlags(obj,value)


            obj.SimulatorFlags=value;
        end

        function set.VerilogLibraryName(obj,value)


            obj.VerilogLibraryName=value;
        end

        function set.VhdlLibraryName(obj,value)


            obj.VhdlLibraryName=value;
        end

        function set.HdlCodeCoverageCompilationFlag(obj,value)


            obj.HdlCodeCoverageCompilationFlag=value;
        end

        function set.HdlCodeCoverageElaborationFlag(obj,value)


            obj.HdlCodeCoverageElaborationFlag=value;
        end

        function set.HdlCodeCoverageSimulationFlag(obj,value)


            obj.HdlCodeCoverageSimulationFlag=value;
        end

        function set.HdlCodeCoverageReportGen(obj,value)


            obj.HdlCodeCoverageReportGen=value;
        end

        function set.HdlCompileTerm(obj,value)


            obj.HdlCompileTerm=value;
        end

        function set.HdlSimInit(obj,value)


            obj.HdlSimInit=value;
        end

        function set.HdlSimCmd(obj,value)


            obj.HdlSimCmd=value;
        end

        function set.HdlSimViewWaveSetupCmd(obj,value)


            obj.HdlSimViewWaveSetupCmd=value;
        end

        function set.HdlSimViewWavePrefix(obj,value)


            obj.HdlSimViewWavePrefix=value;
        end

        function set.HdlSimViewWaveRefPrefix(obj,value)


            obj.HdlSimViewWaveRefPrefix=value;
        end

        function set.HdlSimViewWaveCmd(obj,value)


            obj.HdlSimViewWaveCmd=value;
        end

        function set.HdlSimTerm(obj,value)


            obj.HdlSimTerm=value;
        end

        function set.HdlSimProjectInit(obj,value)


            obj.HdlSimProjectInit=value;
        end

        function set.HdlSimProjectCmd(obj,value)


            obj.HdlSimProjectCmd=value;
        end

        function set.HdlSimProjectTerm(obj,value)


            obj.HdlSimProjectTerm=value;
        end

        function set.HdlSynthTool(obj,value)


            obj.HdlSynthTool=value;
        end

        function set.HdlSynthInit(obj,value)


            obj.HdlSynthInit=value;
        end

        function set.HdlSynthCmd(obj,value)


            obj.HdlSynthCmd=value;
        end

        function set.HdlMapArrow(obj,value)


            obj.HdlMapArrow=value;
        end

        function set.HdlSynthTerm(obj,value)


            obj.HdlSynthTerm=value;
        end

        function set.HdlSynthLibCmd(obj,value)


            obj.HdlSynthLibCmd=value;
        end

        function set.HdlSynthLibSpec(obj,value)


            obj.HdlSynthLibSpec=value;
        end

        function set.InitialValuesDoFile(obj,value)


            obj.InitialValuesDoFile=value;
        end
    end

    methods
        filenames=entityFileNames(~)
        names=entityNames(this)
        [entityPortList,entityRefPortList]=getPortList(this)
        newSimCmd=getTargetSpecificSimCmd(this,simCmd)
        initParams(this,entityNameList,entityPathList,TBFilesList,varargin)
        writeCompileDoFile(this,varargin)
        writeMapFile(this,varargin)
        writeSimDoFile(this,varargin)
        writeSynthesisFile(this,SynthesisTool)
    end


    methods(Hidden)
        disp(this)
        language=getDUTLanguage(this)
        result=hasRefSignal(this,SignalName)
        vmap_cEmitted=insertDSPBACompileScripts(this,fid,vmap_cEmitted)
        insertDSPBASynthesisScripts(this,fid)
        vmap_cEmitted=insertIseXSGCompileScripts(this,fid,vmap_cEmitted)
        insertVivadoXSGCompileScripts(this,topfid,topname)
        simCmd=insertXSGSimScripts(this,origSimCmd)
        insertXSGSynthesisScripts(this,fid)
        writeAllScripts(this,varargin)
        writeSimProjFile(this,varargin)
        writeTargetCodeGenHeaders(this,fid)
    end

end


