function compileHandler=startCompile(this,modelName)




    compileHandler=fixed.internal.modelcompilehandler.ModelCompileHandler(modelName);
    if this.proposalSettings.HandleCompile
        compileHandler.setLicenseType(this.proposalSettings.LicenseType);
        compileHandler.setSimType(this.proposalSettings.SimType);
        compileHandler.start();
    end
end
