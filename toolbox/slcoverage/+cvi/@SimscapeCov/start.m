function start(this)



    try
        if isempty(this.covData)
            this.processPLogData();
        end
        if isempty(this.covData)
            return;
        end
        descr_MSG='MSG_SC_MODE';
        outcome_MSG='MSG_SC_MODE_OUTI';

        meticEnum=cvi.MetricRegistry.getEnum('cvmetric_Simscape_mode');
        for idx=1:numel(this.covData)
            blockP=this.covData(idx).block_path;
            covId=get_param(blockP,'CoverageId');
            if cvi.SimscapeCov.handlePrototypeId()==0
                for mIdx=1:numel(this.covData(idx).modes)
                    mode=this.covData(idx).modes(mIdx);
                    outcomes=num2cell(num2str(mode.outcomes(:)));
                    descr=mode.descr;
                    cv('defineCoverage',covId,meticEnum,descr_MSG,outcome_MSG,descr,outcomes);
                end
            elseif cvi.SimscapeCov.handlePrototypeId()==1
                for mIdx=1:numel(this.covData(idx))
                    allOutcomes=this.covData(idx).outcomes;
                    outcomes={};
                    for oidx=1:size(allOutcomes,1)
                        outcomes{oidx}=num2str(allOutcomes(oidx,:));
                    end
                    descr=this.covData(idx).descr;
                    cv('defineCoverage',covId,meticEnum,descr_MSG,outcome_MSG,descr,outcomes);
                end

            end
        end
    catch MEx
        rethrow(MEx);
    end


