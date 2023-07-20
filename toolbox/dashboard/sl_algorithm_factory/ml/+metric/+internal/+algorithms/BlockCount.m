classdef BlockCount<metric.SimpleMetric


    properties

        filteredList={{'Inport',''},...
        {'Outport',''},...
        {'From',''},...
        {'Goto',''}};
    end

    methods
        function obj=BlockCount()
            obj.AlgorithmID='slcomp.SimulinkBlocks';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function res=algorithm(this,resultFactory,component)

            res=resultFactory.createResult(this.ID,component);
            slHandle=Simulink.ID.getHandle(metric.internal.getSIDFromArtifact(component));
            blocks=find_system(slHandle,'MatchFilter',@Simulink.match.allVariants,'LookUnderMasks','all','FollowLinks','on',...
            'SearchDepth',1,'Type','Block');


            blocks=setdiff(blocks,slHandle);

            bool=true(1,length(blocks));

            for i=1:length(blocks)
                blockType=get_param(blocks(i),'BlockType');
                maskType=get_param(blocks(i),'MaskType');

                for j=1:numel(this.filteredList)
                    if strcmpi(blockType,this.filteredList{j}{1})&&...
                        strcmpi(maskType,this.filteredList{j}{2})
                        bool(i)=false;
                        break;
                    end
                end
            end

            blocks=blocks(bool);
            numBlocks=length(blocks);

            res.Value=uint64(numBlocks);
        end
    end
end
