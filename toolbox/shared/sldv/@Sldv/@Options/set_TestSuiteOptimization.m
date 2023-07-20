function prop=set_TestSuiteOptimization(this,prop)





    if strcmp(prop,'CombinedObjectives (Nonlinear Extended)')
        prop='Auto';
    end

    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'TestSuiteOptimization')
            this.PrivateData.TestSuiteOptimization=prop;
        end
    else
        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'TestSuiteOptimization'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'TestSuiteOptimization'],prop);
        end
    end

end

