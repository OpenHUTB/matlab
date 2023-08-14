classdef CoverageFragment<metric.SimpleMetric



    properties(Constant)
        MetricMap=containers.Map(...
        {'DecisionCoverageFragment','ExecutionCoverageFragment',...
        'ConditionCoverageFragment','MCDCCoverageFragment'},...
        {'decision',cvmetric.Structural.block,'condition','mcdc'});
    end

    methods
        function obj=CoverageFragment()
            obj.AlgorithmID='CoverageFragment';
            obj.addSupportedValueDataType(metric.data.ValueType.DoubleVector);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,artifacts,resources)












            a_model=artifacts(1);
            if numel(artifacts)>1
                as_results=artifacts(2:2:end);
            else
                as_results=[];
            end


            covData=[];
            if~isempty(resources.CoverageFragment)
                covFragment=resources.CoverageFragment(...
                [resources.CoverageFragment.Model]==a_model.Label);
                if~isempty(covFragment)
                    covData=covFragment.CoverageData;
                end
            end



            result=resultFactory.createResult(this.ID,...
            [a_model,as_results]);

            covKey=this.MetricMap(this.ID);
            analysis_model=artifacts(1).Label;


            if~isempty(covData)


                if isequal(covKey,cvmetric.Structural.block)||...
                    covData.test.settings.(covKey)

                    [numSatisfied,numJustified,numTotal]=...
                    SlCov.CoverageAPI.getHitCount(covData,analysis_model,covKey);
                    numSatisfied=double(numSatisfied);
                    numJustified=double(numJustified);
                    numTotal=double(numTotal);

                    if isempty(numTotal)||(0==numTotal)
                        achieved_pc=100;
                        justified_pc=0;
                        missed_pc=0;
                    else
                        achieved_pc=100*(numSatisfied/numTotal);
                        justified_pc=100*(numJustified/numTotal);
                        missed_pc=100*((numTotal-numSatisfied-numJustified)/numTotal);
                    end

                    result.Value=[achieved_pc;justified_pc;missed_pc];
                else
                    result.Value=[];
                end
            else
                result.Value=[];
            end
        end
    end
end
