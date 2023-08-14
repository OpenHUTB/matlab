function needMdlGenForDut=needFullMdlGen(this)







    if this.genmodelgetparameter('CriticalPathEstimation')
        needMdlGenForDut=true;
    elseif this.genmodelgetparameter('StaticLatencyPathAnalysis')
        needMdlGenForDut=true;
    elseif~this.genmodelgetparameter('optimizemdlgen')


        needMdlGenForDut=true;
    elseif isDutWholeModel(this)

        needMdlGenForDut=true;
    else




        needMdlGenForDut=this.needsFullModelGenForDut;
    end

