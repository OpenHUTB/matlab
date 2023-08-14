function prop=set_ModelCoverageObjectives(this,prop)




    if strcmp(prop,'EnhancedMCDC')
        if slavteng('feature','PathBasedTestgen')~=0
            this.PathBasedTestGeneration='on';
        else
            this.PathBasedTestGeneration='off';
            prop='MCDC';
        end
    else
        this.PathBasedTestGeneration='off';
    end

    if~this.checkslavtcchandle
        if isfield(this.PrivateData,'ModelCoverageObjectives')
            this.PrivateData.ModelCoverageObjectives=prop;
        end
    else
        if isa(this.activeCS,'Simulink.ConfigSetRef')
            configset.reference.overrideParameter(this.modelH,[this.extproductTag,'ModelCoverageObjectives'],prop);
        else
            set_param(this.activeCS,[this.extproductTag,'ModelCoverageObjectives'],prop);
        end
    end