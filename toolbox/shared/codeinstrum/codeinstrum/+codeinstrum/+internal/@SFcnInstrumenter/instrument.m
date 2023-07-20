



function[instrumentedFiles,moduleName,extraFiles]=instrument(this,instrOpts)


    assert(isempty(this.SFcnInfo),'The S-Function information must be empty');
    assert(isempty(this.InstrumObj),'The instrumentation object must be empty');

    if nargin<2
        instrOpts=internal.cxxfe.instrum.InstrumOptions();
    end


    this.extractCodeInformation();
    if~isempty(this.SFcnInfo.idxMain)
        moduleName=this.SFcnInfo.name;
    else
        throw(MException(message('CodeInstrumentation:instrumenter:mainSFunctionNotFound')));
    end


    dbFile=fullfile(this.WorkingDir,[moduleName,'.db']);
    if exist(dbFile,'file')
        delete(dbFile);
    end


    this.InstrumObj=codeinstrum.internal.Instrumenter(dbFile,instrOpts);
    this.InstrumObj.moduleName=moduleName;
    this.InstrumObj.outDir=this.WorkingDir;
    this.InstrumObj.outInstrDir=this.WorkingDir;
    if this.hasSldvInfo()
        sldv.code.internal.setCustomMacroEmitter(this.InstrumObj.InstrumImpl);
    end
    if~isempty(this.SLDVInfo)
        this.InstrumObj.serializeFilesWithoutCoverageInDB=true;
    end



    this.InstrumObj.InstrVarRadix=[this.InstrumObj.InstrVarRadix,'_',moduleName];
    if~isempty(this.SFcnInfo.similarNames)
        defaultRadix=this.InstrumObj.InstrVarRadix;
        maxChar=max(cellfun(@numel,this.SFcnInfo.similarNames));
        newRadix=[defaultRadix,repmat('_',1,maxChar-numel(defaultRadix))];
        allNames=[this.SFcnInfo.similarNames(:);{newRadix}];
        allNames=matlab.lang.makeUniqueStrings(allNames,numel(allNames));
        this.InstrumObj.InstrVarRadix=[allNames{end},'_'];

        defaultRadix=this.InstrumObj.InstrFcnRadix;
        newRadix=[defaultRadix,repmat('_',1,maxChar-numel(defaultRadix))];
        this.InstrumObj.InstrFcnRadix=newRadix;
    end


    this.InstrumObj.booleanTypes{end+1}='boolean_T';


    this.InstrumObj.prepareModuleInstrumentation();
    this.InstrumObj.setSourceKind(internal.cxxfe.instrum.SourceKind.SFunction);

    [instrumentedFiles,nbInstrumented]=this.instrumentAllFiles();

    this.InstrumObj.finalizeModuleInstrumentation();
    if nbInstrumented==0
        warning(message('CodeInstrumentation:instrumenter:noInstrumentedSource'));
        extraFiles={};
        return
    end



    extraFiles=this.insertInstrumUtils(instrumentedFiles);

end

