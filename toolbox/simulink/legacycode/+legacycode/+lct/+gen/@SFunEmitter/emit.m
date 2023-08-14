



function emit(this,varargin)


    narginchk(1,2);


    if~this.LctSpecInfo.InfoExtracted||~this.LctSpecInfo.BusInfoExtracted
        this.LctSpecInfo.extractAllInfo('c');
    end



    if this.LctSpecInfo.Specs.Options.singleCPPMexFile&&...
        this.LctSpecInfo.canUseSFunCgAPI==false

        if~isempty(this.LctSpecInfo.sfunCgWarningID)
            warning(message(['Simulink:tools:',this.LctSpecInfo.sfunCgWarningID]));
        end


        this.LctSpecInfo.Specs.Options.singleCPPMexFile=false;
    end


    if~this.LctSpecInfo.isCPP&&~this.LctSpecInfo.canUseSFunCgAPI
        fExt='.c';
    else
        fExt='.cpp';
    end
    this.Filename=[this.LctSpecInfo.Specs.SFunctionName,fExt];







    if legacycode.LCT.conflictingCFileExists(this.LctSpecInfo.Specs)
        throw(MException(message('Simulink:tools:LCTWarnFileConflict',this.Filename)));
    end


    this.HasBusInfoToRegister=~this.LctSpecInfo.Specs.Options.stubSimBehavior&&...
    size(this.LctSpecInfo.DataTypes.BusInfo.BusElementHashTable,1)>0;
    this.HasSampleTimeAsParameter=strcmpi(this.LctSpecInfo.SampleTime,'parameterized');


    if nargin==2
        outWriter=varargin{1};
        validateattributes(outWriter,{'legacycode.lct.gen.BufferedWriter'},...
        {'scalar','nonempty'},2);
    else

        outWriter=legacycode.lct.gen.BufferedFileWriter(this.Filename,false,false);
    end


    codeWriter=legacycode.lct.gen.CxxCodeWriter(outWriter);


    this.emitHeader(codeWriter);
    this.emitDefines(codeWriter);
    this.emitCheckParameters(codeWriter);
    this.emitInitializeSizes(codeWriter);
    this.emitInitializeSampleTimes(codeWriter);
    this.emitSetInputPortDimensionInfo(codeWriter);
    this.emitSetOutputPortDimensionInfo(codeWriter);
    this.emitSetDefaultPortDimensionInfo(codeWriter);
    this.emitSetWorkWidths(codeWriter);
    this.emitStart(codeWriter);
    this.emitInitializeConditions(codeWriter);
    this.emitOutputs(codeWriter);
    this.emitTerminate(codeWriter);
    this.emitSFunCgClass(codeWriter);
    this.emitTrailer(codeWriter);


