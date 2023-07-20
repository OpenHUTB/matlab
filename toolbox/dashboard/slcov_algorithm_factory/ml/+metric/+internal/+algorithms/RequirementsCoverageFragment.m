






classdef RequirementsCoverageFragment<metric.SimpleMetric



    properties(Constant)
        MetricMap=containers.Map(...
        {'RequirementsDecisionCoverageFragment','RequirementsExecutionCoverageFragment',...
        'RequirementsConditionCoverageFragment','RequirementsMCDCCoverageFragment'},...
        {'decision',cvmetric.Structural.block,'condition','mcdc'});
    end

    methods
        function obj=RequirementsCoverageFragment()
            obj.AlgorithmID='RequirementsCoverageFragment';
            obj.addSupportedValueDataType(metric.data.ValueType.Fraction);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,artifacts,resources)









            result=resultFactory.createResult(this.ID,alm.Artifact.empty);
            result.Value=[];




            a_model=artifacts(1);
            if numel(artifacts)>1
                as_results=artifacts(2:2:end);
            else
                as_results=[];
            end

            [cdsBase,cdsReqs]=splitCoverageDataServiceResources(resources,...
            'CoverageDataServiceRequirements');
            if isempty(cdsBase)
                return;
            end

            coverageKey=this.MetricMap(this.ID);

            base=getAggregatedCoverage(cdsBase,{a_model.Label},coverageKey);
            reqs=getAggregatedCoverage(cdsReqs,{a_model.Label},coverageKey);

            result=resultFactory.createResult(this.ID,[a_model,as_results]);

            if isempty(base)
                result.Value=[];
            elseif isempty(reqs)
                if base.satisfied==0

                    result.Value=struct(...
                    'Numerator',0,...
                    'Denominator',1);
                else
                    result.Value=struct(...
                    'Numerator',0,...
                    'Denominator',base.satisfied);
                end
            elseif base.total==0

                result.Value=struct(...
                'Numerator',1,...
                'Denominator',1);
            elseif base.satisfied==0

                result.Value=struct(...
                'Numerator',0,...
                'Denominator',1);
            else
                result.Value=struct(...
                'Numerator',reqs.satisfied,...
                'Denominator',base.satisfied);
            end

        end
    end
end
