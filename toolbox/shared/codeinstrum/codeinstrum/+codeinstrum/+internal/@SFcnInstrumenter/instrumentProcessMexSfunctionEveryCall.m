



function[instrumentedFile,extraFiles]=instrumentProcessMexSfunctionEveryCall(this,mexPath)

    extraFiles={};

    ctx=this.setupContext();
    ctx=this.updateContextForSource(ctx,this.SFcnInfo.idxMain(1),this.SFcnInfo.idxMain(2));
    ctx.extraOpts.instrumentedSrcFile=[tempname(this.InstrumObj.outInstrDir),ctx.srcExt];
    ctx.extraOpts.forOriginalMain=true;
    ctx=instrumentBeforeParsing(this,ctx);

    ctx.extraOpts.extraFeHandlers={codeinstrum.internal.CodeInstrumenterFEHandler(...
    this.InstrumObj,...
    codeinstrum.internal.CodeInstrumenterFEHandler.CODEINSTRUM_PROCESSMEXEVERYCALL_ONLY)};
    ctx.extraOpts.customFeHandlerOnly=true;

    savedVal=this.InstrumObj.dbFilePath;
    this.InstrumObj.dbFilePath='';
    try
        this.InstrumObj.instrumentFile(ctx.currSource,ctx.feOpts,ctx.extraOpts);
        instrumentedFile=ctx.extraOpts.instrumentedSrcFile;
    catch ME
        if codeinstrumprivate('feature','disableErrorRecovery')
            rethrow(ME);
        end
        instrumentedFile=ctx.currSource;
        return
    end
    this.InstrumObj.dbFilePath=savedVal;

    extraFiles=this.insertInstrumUtils({instrumentedFile},mexPath);
