classdef SLDecisionCount<metric.SimpleMetric


    properties

    end

    methods
        function obj=SLDecisionCount()
            obj.AlgorithmID='slcomp.SimulinkDecisions';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
            blks=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
            'SearchDepth',1,'Type','Block');
            helper=metric.internal.algorithms.SLDecisionCountHelper;
            res.Value=uint64(0);
            for i=1:numel(blks)
                res.Value=res.Value+uint64(helper.calculateSLDecisionCount(blks(i)));
            end
        end
    end
end
