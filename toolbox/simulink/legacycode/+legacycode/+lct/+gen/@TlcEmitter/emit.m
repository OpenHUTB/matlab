



function emit(this,varargin)


    narginchk(1,2);



    if~this.LctSpecInfo.InfoExtracted
        this.LctSpecInfo.extractAllInfo('tlc');
    end



    this.LctSpecInfo.hasWrapper=true;


    if this.LctSpecInfo.Specs.Options.singleCPPMexFile&&this.LctSpecInfo.canUseSFunCgAPI==true
        warning(message('Simulink:tools:LCTSFcnCppCodeAPIWarningSkipTLC',...
        this.LctSpecInfo.Specs.SFunctionName));
        return
    end


    this.LctSpecInfo.Specs.Options.singleCPPMexFile=false;


    if nargin==2
        outWriter=varargin{1};
        validateattributes(outWriter,{'legacycode.lct.gen.BufferedWriter'},...
        {'scalar','nonempty'},2);
    else
        fileName=[this.LctSpecInfo.Specs.SFunctionName,'.tlc'];
        outWriter=legacycode.lct.gen.BufferedFileWriter(fileName);
    end


    this.HeaderFileInfo=this.LctSpecInfo.extractAllHeaderFiles();
    this.HasWrapperOrIsCxx=this.LctSpecInfo.hasWrapper||this.LctSpecInfo.isCPP;


    codeWriter=legacycode.lct.gen.TlcCodeWriter(outWriter);


    this.emitHeader(codeWriter);
    this.emitBlockTypeSetup(codeWriter);
    this.emitBlockInstanceSetup(codeWriter);
    this.emitStart(codeWriter);
    this.emitInitializeConditions(codeWriter);
    this.emitOutputs(codeWriter);
    this.emitBlockOutputSignal(codeWriter);
    this.emitTerminate(codeWriter);
    this.emitTrailer(codeWriter);


