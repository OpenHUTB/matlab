






classdef UnitBoundaryCoverageBreakdown<metric.GraphMetric

    properties(Constant)
        MetricMap=containers.Map(...
        {'UnitBoundaryDecisionCoverageBreakdown','UnitBoundaryExecutionCoverageBreakdown',...
        'UnitBoundaryConditionCoverageBreakdown','UnitBoundaryMCDCCoverageBreakdown'},...
        {'decision',cvmetric.Structural.block,'condition','mcdc'});
    end

    methods

        function obj=UnitBoundaryCoverageBreakdown()
            obj.AlgorithmID='UnitBoundaryCoverageBreakdown';

            obj.addSupportedValueDataType(metric.data.ValueType.Fraction);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,queryResult,resources)







            result=resultFactory.createResult(this.ID,alm.Artifact.empty);
            result.Value=[];





            seqs=queryResult.getSequences();
            if isempty(seqs)||isempty(seqs{1})
                return;
            end

            as_models=cellfun(@(x)x{1},seqs)';

            if numel(seqs{1})>1
                tmp=seqs{1}(2:2:end);
                as_results=[tmp{:}];
            else
                as_results=[];
            end

            a_model=as_models(1);

            [cdsBase,cdsUnit]=splitCoverageDataServiceResources(resources,...
            'CoverageDataServiceUnitBoundary');
            if isempty(cdsBase)||isempty(cdsUnit)
                return;
            end

            modelNames={as_models.Label};
            coverageKey=this.MetricMap(this.ID);

            base=getAggregatedCoverage(cdsBase,modelNames,coverageKey);
            unit=getAggregatedCoverage(cdsUnit,modelNames,coverageKey);

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

