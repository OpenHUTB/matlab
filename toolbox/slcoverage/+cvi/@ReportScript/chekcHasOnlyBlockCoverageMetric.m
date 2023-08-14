function res=chekcHasOnlyBlockCoverageMetric(this,blkEntry)




    res=false;
    if isempty(this.metricNames)
        for idx=1:numel(this.toMetricNames)
            mn=this.toMetricNames{idx};
            if~strcmpi(mn,'cvmetric_Structural_block')&&...
                ~isempty(blkEntry.(mn))
                return;
            end
        end
        res=true;
    end

