function emit(this,outWriter)





    narginchk(2,2);

    validateattributes(outWriter,{'legacycode.lct.gen.BufferedWriter'},...
    {'scalar','nonempty'},2);


    codeWriter=rtw.connectivity.CodeWriter.create(...
    'language','MATLAB','callCBeautifier',false,...
    'writerObject',outWriter);


    this.EmittingObjsHasLibs=this.hasLibDependencyInfo();
    this.EmittingObjsIsSingleCPPMexFile=this.isSingleCPPMexFile();


    this.emitHeader(codeWriter);
    this.emitBodyStart(codeWriter);
    this.emitBody(codeWriter);
    this.emitBodyEnd(codeWriter);
    this.emitSerializedInfo(codeWriter);
    this.emitHelpers(codeWriter);
    this.emitTrailer(codeWriter);


