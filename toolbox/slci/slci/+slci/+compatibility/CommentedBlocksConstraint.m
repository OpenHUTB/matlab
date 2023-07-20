



classdef CommentedBlocksConstraint<slci.compatibility.Constraint



    methods(Access=private)

        function out=findAllCommentedBlocks(~,h)
            out=[];


            blkList=find_system(h,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'IncludeCommented','on');


            for i=2:numel(blkList)
                if(strcmpi(get_param(blkList(i),'Type'),'block')...
                    &&strcmpi(get_param(blkList(i),'Commented'),'on'))

                    out(end+1)=blkList(i);%#ok
                end
            end
        end
    end

    methods

        function obj=CommentedBlocksConstraint()
            obj.setEnum('CommentedBlocks');
            obj.setCompileNeeded(0);
            obj.setFatal(false);
        end


        function out=getDescription(aObj)%#ok
            out=DAStudio.message('Slci:compatibility:CommentedBlocks');
        end


        function out=check(aObj)
            out=[];

            mdl=aObj.ParentModel().getHandle();
            commentedBlocksList=aObj.findAllCommentedBlocks(mdl);

            if~isempty(commentedBlocksList)

                out=slci.compatibility.Incompatibility(...
                aObj,...
                'CommentedBlocks');
                commentedBlocksName={};
                for i=1:numel(commentedBlocksList)
                    commentedBlocksName{end+1}=Simulink.ID.getSID(commentedBlocksList(i));%#ok
                end
                out.setObjectsInvolved(commentedBlocksName);
            end
        end

    end
end
