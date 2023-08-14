






classdef UnitBoundaryCoverageFragment<metric.SimpleMetric



    properties(Constant)
        MetricMap=containers.Map(...
        {'UnitBoundaryDecisionCoverageFragment','UnitBoundaryExecutionCoverageFragment',...
        'UnitBoundaryConditionCoverageFragment','UnitBoundaryMCDCCoverageFragment'},...
        {'decision',cvmetric.Structural.block,'condition','mcdc'});
    end

    methods
        function obj=UnitBoundaryCoverageFragment()
            obj.AlgorithmID='UnitBoundaryCoverageFragment';
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

            [cdsBase,cdsUnit]=splitCoverageDataServiceResources(resources,...
            'CoverageDataServiceUnitBoundary');
            if isempty(cdsBase)||isempty(cdsUnit)
                return;
            end

            coverageKey=this.MetricMap(this.ID);

            base=getAggregatedCoverage(cdsBase,{a_model.Label},coverageKey);
            unit=getAggregatedCoverage(cdsUnit,{a_model.Label},coverageKey);

            result=resultFactory.createResult(this.ID,[a_model,as_results]);

            if isempty(base)||isempty(unit)
                result.Value=[];
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
                'Numerator',unit.satisfied,...
                'Denominator',base.satisfied);
            end

        end
    end
end
