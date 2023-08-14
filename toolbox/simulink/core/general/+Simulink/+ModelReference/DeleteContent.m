




classdef DeleteContent<handle
    properties(SetAccess=private,GetAccess=private)
System
    end


    properties(Constant,Access=private)
        SearchParams=Simulink.ModelReference.DeleteContent.getSearchParams();
    end


    methods(Static,Access=public)
        function args=getSearchParams()
            args={'LookUnderMasks','all','FollowLinks','on','IncludeCommented','on',...
            'MatchFilter',@Simulink.match.allVariants};
        end
        function deleteContents(subsys)
            this=Simulink.ModelReference.DeleteContent(subsys);
            this.deleteBlocks;
            this.deleteLines;
            this.deleteAnnotations;
        end
    end


    methods(Access=private)
        function this=DeleteContent(subsys)

            type=get_param(subsys,'Type');
            if type=="block"
                permission=get_param(subsys,'Permissions');
                if permission=="ReadOnly"||permission=="NoReadOrWrite"
                    DAStudio.error('Simulink:blocks:SubsysWriteProtected',subsys);
                end
            end

            this.System=get_param(subsys,'Handle');
        end


        function deleteBlocks(this)
            handles=find_system(this.System,'SearchDepth',1,this.SearchParams{:});
            arrayfun(@(block)this.delete_block(block),handles(2:end));
        end


        function deleteLines(this)
            handles=find_system(this.System,'FindAll',true,this.SearchParams{:},'Type','line');
            delete_line(handles);
        end


        function deleteAnnotations(this)
            handles=find_system(this.System,'FindAll',true,this.SearchParams{:},'Type','annotation');
            delete(handles);
        end
    end


    methods(Static,Access=private)
        function delete_block(block)
            if ishandle(block)
                delete_block(block);
            end
        end
    end
end