function prop=get_TestSuiteOptimization(this,prop)





    allow_legacy=false;

    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'TestSuiteOptimization')
            prop=this.PrivateData.TestSuiteOptimization;
        end


        allow_legacy=false;

        if isfield(this.PrivateData,'AllowLegacyTestSuiteOptimization')
            allow_legacy=strcmp(this.PrivateData.AllowLegacyTestSuiteOptimization,'on');
        end
    else
        prop=get_param(this.activeCS,[this.extproductTag,'TestSuiteOptimization']);

        allow_legacy=false;
    end



    if(~allow_legacy&&any(strcmp(prop,{'CombinedObjectives','LargeModel'})))||...
        strcmp(prop,'CombinedObjectives (Nonlinear Extended)')
        prop='Auto';
    end

end
