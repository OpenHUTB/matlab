function execute(this)





    topModel=this.refMdls{end};
    originalSimMode=get_param(topModel,'SimulationMode');
    set_param(topModel,'SimulationMode','Normal');




    modelState=Simulink.internal.TemporaryModelState(this.simIn(1),'EnableConfigSetRefUpdate','on');
    modelState.RevertOnDelete=false;
    compileHandler=startCompile(this,topModel);
    skipSystem=false;
    topSys=get_param(this.sysToScaleName,'Object');
    if isa(topSys,'Simulink.SubSystem')&&topSys.isPostCompileVirtual

        skipSystem=true;
    end


    errorException=[];
    try
        if~skipSystem
            this.performCollection();
        end
    catch scaleError
        errorException=scaleError;
    end

    try
        stopCompile(this,compileHandler);
        revert(modelState);
        this.updateParametersForScenarios();
        set_param(topModel,'SimulationMode',originalSimMode);
    catch engineTermFail
        rethrow(engineTermFail);
    end

    if~isempty(errorException)
        rethrow(errorException);
    end




    this.performSharing();

end


