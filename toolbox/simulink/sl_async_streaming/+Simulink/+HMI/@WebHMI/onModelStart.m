function onModelStart(this,startTime,stopTime)



    simTarget=get_param(this.Model,'ModelReferenceTargetType');
    this.handleModelReference(~strcmpi(simTarget,'none'));


    this.handleUnsupportedSimMode(get_param(this.Model,'SimulationMode'));


    mi=get_param(this.Model,'DataLoggingOverride');
    if~isempty(mi)
        sw=warning('off','all');
        tmp=onCleanup(@()warning(sw));
        mi=validate(mi,this.Model,false,false,true,'remove');
    end
    this.handleLoggingOverride(mi);


    if~this.IsInModelReference
        this.updateVariableControls();
        this.startStreaming(startTime,stopTime);
    end
end

