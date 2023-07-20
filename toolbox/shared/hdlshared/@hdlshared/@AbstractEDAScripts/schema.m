function schema






    mlock;

    pkg=findpackage('hdlshared');
    this=schema.class(pkg,'AbstractEDAScripts');


    if isempty(findtype('HDLTargetLanguage'))
        schema.UserType('HDLTargetLanguage','string',...
        @checkHDLTargetLanguage);
    end


    schema.prop(this,'TopLevelName','ustring');
    schema.prop(this,'TestBenchName','ustring');
    schema.prop(this,'TestBenchFilesList','string vector');
    schema.prop(this,'EntityPathList','string vector');
    schema.prop(this,'EntityNamelist','string vector');
    schema.prop(this,'SubModelData','mxArray');
    schema.prop(this,'TargetLanguage','HDLTargetLanguage');
    schema.prop(this,'HDLCodeCoverage','bool');

    schema.prop(this,'SimulationTool','ustring');

    schema.prop(this,'IsVHDL','bool');
    p.AccessFlags.PublicSet='Off';
    p.AccessFlags.PublicGet='Off';
    p.Visible='On';

    p=schema.prop(this,'IsVerilog','bool');
    p.AccessFlags.PublicSet='Off';
    p.AccessFlags.PublicGet='Off';
    p.Visible='On';

    p=schema.prop(this,'IsSystemVerilog','bool');
    p.AccessFlags.PublicSet='Off';
    p.AccessFlags.PublicGet='Off';
    p.Visible='On';

    schema.prop(this,'CodeGenDirectory','ustring');
    schema.prop(this,'IsTopModel','bool');

    schema.prop(this,'GenerateCompileDoFile','bool');
    schema.prop(this,'GenerateTBCompileDoFile','bool');
    schema.prop(this,'GenerateSimDoFile','bool');
    schema.prop(this,'GenerateSimProjectFile','bool');
    schema.prop(this,'GenerateSynthesisFile','bool');
    schema.prop(this,'GenerateMapFile','bool');
    schema.prop(this,'GenerateTargetCodegenFile','bool');

    schema.prop(this,'CompileDoFilePostFix','ustring');
    schema.prop(this,'SimDoFilePostFix','ustring');
    schema.prop(this,'SimProjectFilePostFix','ustring');
    schema.prop(this,'SynthesisFilePostFix','ustring');
    schema.prop(this,'MapFilePostFix','ustring');

    schema.prop(this,'HdlCompileInit','ustring');
    schema.prop(this,'HdlCompileVhdlCmd','ustring');
    schema.prop(this,'HdlCompileVerilogCmd','ustring');
    schema.prop(this,'HdlElaborationCmd','ustring');
    schema.prop(this,'HdlElaborationFlags','ustring');

    schema.prop(this,'SimulatorFlags','ustring');
    schema.prop(this,'VerilogLibraryName','ustring');
    schema.prop(this,'VhdlLibraryName','ustring');

    schema.prop(this,'HdlCodeCoverageCompilationFlag','ustring');
    schema.prop(this,'HdlCodeCoverageElaborationFlag','ustring');
    schema.prop(this,'HdlCodeCoverageSimulationFlag','ustring');
    schema.prop(this,'HdlCodeCoverageReportGen','ustring');


    schema.prop(this,'HdlCompileTerm','ustring');
    schema.prop(this,'HdlSimInit','ustring');
    schema.prop(this,'HdlSimCmd','ustring');

    schema.prop(this,'HdlSimViewWaveSetupCmd','ustring');

    schema.prop(this,'HdlSimViewWavePrefix','ustring');
    schema.prop(this,'HdlSimViewWaveRefPrefix','ustring');

    schema.prop(this,'HdlSimViewWaveCmd','ustring');
    schema.prop(this,'HdlSimTerm','ustring');
    schema.prop(this,'HdlSimProjectInit','ustring');
    schema.prop(this,'HdlSimProjectCmd','ustring');
    schema.prop(this,'HdlSimProjectTerm','ustring');
    schema.prop(this,'HdlMapArrow','ustring');
    schema.prop(this,'HdlSynthTool','ustring');
    schema.prop(this,'HdlSynthInit','ustring');
    schema.prop(this,'HdlSynthCmd','ustring');
    schema.prop(this,'HdlMapArrow','ustring');
    schema.prop(this,'HdlSynthTerm','ustring');
    schema.prop(this,'HdlSynthLibCmd','ustring');
    schema.prop(this,'HdlSynthLibSpec','ustring');
    schema.prop(this,'InitialValuesDoFile','ustring');

    schema.prop(this,'ScriptGenSuccessful','bool');




    function checkHDLTargetLanguage(lang)

        if nnz(strcmpi({'vhdl','verilog','systemverilog'},lang))~=1
            error(message('HDLShared:hdlshared:invalidhandle'));
        end


