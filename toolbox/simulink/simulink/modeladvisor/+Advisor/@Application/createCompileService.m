













function createCompileService(this,models,rootmodel,modes)


    if any(modes==Advisor.CompileModes.CGIR)
        this.TaskManager.registerCGIRInspectorsForSelectedTasks();
    end
    if any(modes==Advisor.CompileModes.SLDV)
        this.TaskManager.registerSLDVOptionsForSelectedTasks();
    end

    this.CompileService=Advisor.internal.services.CompileService(...
    this.ID);
    this.CompileService.setCompileModes(modes);


    hTop=get_param(rootmodel,'Handle');
    hModels=get_param(models,'Handle');

    this.CompileService.setModels(hTop,[hModels{:}]);


    this.CompileService.addlistener('Compiled',...
    @(src,evt)compileCallbackFct(this,src,evt));

    this.CompileService.addlistener('CompileFailed',...
    @(src,evt)compileFailedCallbackFct(this,src,evt));


end

