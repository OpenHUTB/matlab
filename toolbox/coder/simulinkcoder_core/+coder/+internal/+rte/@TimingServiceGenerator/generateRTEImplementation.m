



function generateRTEImplementation(this,codeDescriptor)
    platformServices=codeDescriptor.getServices();
    if isempty(platformServices)
        return;
    end
    timerInterface=platformServices.getServiceInterface(...
    coder.descriptor.Services.Timer);
    if isempty(timerInterface)
        return;
    end

    model=codeDescriptor.ModelName;

    this.RTEUtil.displayProgressInfo(model,'source',this.RTEImplementationFilename);


    sourceFileName=fullfile(this.RTEOutFolder,this.RTEImplementationFilename);
    writer=rtw.connectivity.CodeWriter.create('filename',sourceFileName);

    switch this.PluginContext
    case coder.internal.rte.PluginContext.Deployment
        this.generateImplemenationForNativeApplication(model,platformServices,writer);
    case coder.internal.rte.PluginContext.XIL
        this.generateImplemenationForSIL(model,platformServices,writer);
    otherwise
        assert(false,'Unexpected plugin context encountered');
    end

end


