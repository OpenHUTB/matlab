

classdef RevertActions<handle
    methods(Static,Access=public)
        function openRevertDialogAction(~)
            import simulink.search.SearchActions;
            import simulink.search.RevertActions;
            studioTag=SearchActions.getActiveStudioTag();
            RevertActions.openRevertDialog(studioTag);
        end

        function openRevertDialog(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);
            replaceManager.openRevertDialog(studioTag);
        end

        function varargout=removeErrorsAndGetRevertRecords(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);
            varargout{1}=values(replaceManager.removeErrorsAndGetRevertRecords());
        end

        function varargout=getRevertRecords(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);
            varargout{1}=values(replaceManager.getRevertRecords());
        end

        function varargout=revertRecords(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);

            [revertInfoManager,errorManager]=replaceManager.revertRecords(...
            varargin{2}...
            );
            varargout{1}=revertInfoManager;
            varargout{2}=errorManager;
        end

        function varargout=revertSingleMatch(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);



            [revertInfoManager,errorManager]=replaceManager.revertSingleMatch(...
            varargin{2},...
            varargin{3},...
            varargin{4}...
            );
            varargout{1}=revertInfoManager;
            varargout{2}=errorManager;
        end


        function varargout=revertAll(varargin)
            import simulink.search.internal.ReplaceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            replaceManager=ReplaceManager.getReplaceManager(studioTag);
            [revertInfoManager,errorManager]=replaceManager.revertAllRecords();
            varargout{1}=revertInfoManager;
            varargout{2}=errorManager;
        end
    end
end
