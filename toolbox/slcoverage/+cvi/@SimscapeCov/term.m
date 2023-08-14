function term(this)



    try
        if isempty(this.covData)
            return;
        end


        metricEnum=cvi.MetricRegistry.getEnum('cvmetric_Simscape_mode');

        for bIdx=1:numel(this.covData)
            blockP=this.covData(bIdx).block_path;
            covId=get_param(blockP,'CoverageId');
            if cvi.SimscapeCov.handlePrototypeId()==0
                for mIdx=1:numel(this.covData(bIdx).modes)
                    for oIdx=1:numel(this.covData(bIdx).modes(mIdx).outcomes)

                        cv('updateCoverage',covId,metricEnum,0,oIdx-1,this.covData(bIdx).modes(mIdx).hitCounts(oIdx));
                    end
                end
            elseif cvi.SimscapeCov.handlePrototypeId()==1
                for mIdx=1:numel(this.covData(bIdx))
                    for oIdx=1:numel(this.covData(bIdx).hitCounts)

                        cv('updateCoverage',covId,metricEnum,0,oIdx-1,this.covData(bIdx).hitCounts(oIdx));
                    end
                end
            end
        end
    catch MEx
        rethrow(MEx);
    end



