classdef SignalLineCount<metric.SimpleMetric


    properties

    end

    methods
        function obj=SignalLineCount()
            obj.AlgorithmID='slcomp.SimulinkSignalLines';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
            lines=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
            'SearchDepth',1,'FindAll','on','Type','line');
            numLines=length(lines);
            res.Value=uint64(numLines);
        end
    end
end
