classdef CoverageBreakdown<metric.GraphMetric



    properties(Constant)
        MetricMap=containers.Map(...
        {'DecisionCoverageBreakdown','ExecutionCoverageBreakdown',...
        'ConditionCoverageBreakdown','MCDCCoverageBreakdown'},...
        {'decision',cvmetric.Structural.block,'condition','mcdc'});
    end

    methods
        function obj=CoverageBreakdown()
            obj.AlgorithmID='CoverageBreakdown';

            obj.addSupportedValueDataType(metric.data.ValueType.DoubleVector);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,queryResult,resources)










            seqs=queryResult.getSequences();

            if isempty(seqs)||isempty(seqs{1})
                result=resultFactory.createResult(this.ID,alm.Artifact.empty);
                result.Value=[];
                return;
            end

            as_models=cellfun(@(x)x{1},seqs)';
            if numel(seqs{1})>1
                tmp=seqs{1}(2:2:end);
                as_results=[tmp{:}];
            else
                as_results=[];
            end



            aggrNumSatisfied=0;
            aggrNumJustified=0;
            aggrNumTotal=0;

            anyCoverage=false;

            if isempty(resources.CoverageFragment)



                result=resultFactory.createResult(this.ID,alm.Artifact.empty);
                result.Value=[];
                return
            end

            for k=1:numel(as_models)

                a_model=as_models(k);



                result=resultFactory.createResult(this.ID,...
                [a_model,as_results]);


                covFragment=resources.CoverageFragment(...
                [resources.CoverageFragment.Model]==a_model.Label);
                if~isempty(covFragment)
                    covData=covFragment.CoverageData;
                end

                if isempty(covData)
                    continue
                end

                covKey=this.MetricMap(this.ID);
                analysis_model=a_model.Label;


                if isequal(covKey,cvmetric.Structural.block)||covData.test.settings.(covKey)

                    [numSatisfied,numJustified,numTotal]=...
                    SlCov.CoverageAPI.getHitCount(covData,analysis_model,covKey);

                    aggrNumSatisfied=aggrNumSatisfied+numSatisfied;
                    aggrNumJustified=aggrNumJustified+numJustified;
                    aggrNumTotal=aggrNumTotal+numTotal;

                    anyCoverage=true;
                end
            end

            if~anyCoverage
                result.Value=[];
            elseif isempty(aggrNumTotal)||(0==aggrNumTotal)
                achieved_pc=100;
                justified_pc=0;
                missed_pc=0;
                result.Value=[achieved_pc;justified_pc;missed_pc];
            else
                aggrNumSatisfied=double(aggrNumSatisfied);
                aggrNumTotal=double(aggrNumTotal);
                aggrNumJustified=double(aggrNumJustified);
                achieved_pc=100*(aggrNumSatisfied/aggrNumTotal);
                justified_pc=100*(aggrNumJustified/aggrNumTotal);
                missed_pc=100*(aggrNumTotal-aggrNumSatisfied-aggrNumJustified)/aggrNumTotal;
                result.Value=[achieved_pc;justified_pc;missed_pc];
            end
        end
    end
end
