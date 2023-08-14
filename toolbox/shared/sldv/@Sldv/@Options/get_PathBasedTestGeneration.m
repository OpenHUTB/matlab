function prop=get_PathBasedTestGeneration(this,prop)




    if strcmp(prop,'on')
        if this.checkslavtcchandle
            modelCoverageObjectives=this.activeCS.get_param([this.extproductTag,'ModelCoverageObjectives']);
        else
            modelCoverageObjectives=this.ModelCoverageObjectives;
        end
        isEnhancedMCDC=strcmp(modelCoverageObjectives,'EnhancedMCDC');
        assert(isEnhancedMCDC,'Path based test generation to be on only with Enhanced MCDC');
    end
