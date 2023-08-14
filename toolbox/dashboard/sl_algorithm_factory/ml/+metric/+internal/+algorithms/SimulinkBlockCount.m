classdef SimulinkBlockCount<metric.SimpleMetric




    properties

    end

    methods
        function obj=SimulinkBlockCount()
            obj.AlgorithmID='SimulinkBlockCount';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);

            slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));

            blocks=find_system(slHandle,...
            'LookUnderMasks','all',...
            'FollowLinks','on',...
            'MatchFilter',@Simulink.match.allVariants,...
            'SearchDepth',1,...
            'Type','Block');


            blocks=setdiff(blocks,slHandle);


            maskTypes=get_param(blocks,'MaskType');
            blocks=blocks(~strcmp(maskTypes,'System Requirement Item'));

            numBlocks=length(blocks);

            res.Value=uint64(numBlocks);
        end
    end
end
