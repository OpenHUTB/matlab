function choice=getChoice(this)





    choice=4;

    controlFileParam=this.getImplParams('TracebackStagesPerPipeline');

    if~isempty(controlFileParam)
        choice=controlFileParam;

    end
