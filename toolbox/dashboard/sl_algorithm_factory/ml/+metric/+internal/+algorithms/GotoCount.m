classdef GotoCount<metric.SimpleMetric


    properties

    end

    methods
        function obj=GotoCount()
            obj.AlgorithmID='slcomp.SimulinkGotos';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
            gotos=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
            'SearchDepth',1,'BlockType','Goto');
            res.Value=uint64(length(gotos));
        end
    end
end
