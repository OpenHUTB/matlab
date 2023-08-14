



function emit(this,varargin)


    narginchk(1,2);


    if~this.LctSpecInfo.InfoExtracted||~this.LctSpecInfo.BusInfoExtracted
        this.LctSpecInfo.extractAllInfo('c');
    end



    if this.LctSpecInfo.Specs.Options.singleCPPMexFile&&...
        this.LctSpecInfo.canUseSFunCgAPI==false

        if~isempty(this.LctSpecInfo.sfunCgWarningID)
            error(message(['Simulink:tools:',this.LctSpecInfo.sfunCgWarningID]));
        end
    end


    if nargin==2
        outWriter=varargin{1};
        validateattributes(outWriter,{'legacycode.lct.gen.BufferedWriter'},...
        {'scalar','nonempty'},2);
        ownWriter=false;
    else

        outWriter=legacycode.lct.gen.BufferedWriter();
        ownWriter=true;
    end


    codeWriter=legacycode.lct.gen.CxxCodeWriter(outWriter);


    this.emitClass(codeWriter);


    if ownWriter
        disp(outWriter.TxtBuffer);
    end


