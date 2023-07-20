classdef BlockActions<DataTypeOptimization.Preprocessing.PreprocessingActions






    methods(Hidden)
        function allBlocks=getAllBlocks(~,environmentContext)
            allModels=environmentContext.AllModelsUnderSUD;

            if Simulink.internal.useFindSystemVariantsMatchFilter()
                findBlockFunc=@(model)find_system(model,...
                'MatchFilter',@Simulink.match.activeVariants,...
                'IncludeCommented','off',...
                'SearchDepth',inf,...
                'LookUnderMasks','none',...
                'FollowLinks','off',...
                'LockScale','off');
            else
                findBlockFunc=@(model)find_system(model,...
                'Variants','ActiveVariants',...
                'IncludeCommented','off',...
                'SearchDepth',inf,...
                'LookUnderMasks','none',...
                'FollowLinks','off',...
                'LockScale','off');
            end

            allBlocks=[];
            for mIndex=1:numel(allModels)
                blockDiagramName=allModels{mIndex};



                blockDiagramObject=get_param(blockDiagramName,'Object');


                allBlockPaths=findBlockFunc(blockDiagramObject.getFullName);


                allBlocksCell=get_param(allBlockPaths,'Object');
                allBlocks=[allBlocks,allBlocksCell{:}];%#ok<AGROW>
            end
        end

    end
end
