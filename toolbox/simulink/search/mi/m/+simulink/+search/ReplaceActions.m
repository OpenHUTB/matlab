

classdef ReplaceActions<handle
    methods(Static,Access=public)


        function varargout=replaceProperties(varargin)
            import simulink.search.internal.SearchInstanceManager;
            studioTag=varargin{1};
            if isempty(studioTag)

                studioTag='';
            end
            varargout={[],[]};
            searchManager=SearchInstanceManager.getSearchInstanceManager(studioTag);
            if isempty(searchManager)
                return;
            end



            import simulink.search.internal.Util;
            import simulink.search.internal.control.SchedulerByQuantity;
            import simulink.search.internal.control.ReplaceFeedbackManager;
            searchReplaceChannel=['/',studioTag,Util.SEARCH_REPLACE_CHANNEL];
            propsToReplace=varargin{2};
            feedbackScheduler=SchedulerByQuantity(10,200,numel(propsToReplace));
            feedbackManager=ReplaceFeedbackManager(...
            feedbackScheduler,searchReplaceChannel,'replaceFeedback'...
            );

            if nargin>2
                timeStamp=varargin{3};
            else
                timeStamp='ReplaceAll';
            end




            searchManager.replaceProperties(...
            propsToReplace,timeStamp,feedbackManager,feedbackManager...
            );


            varargout{1}=feedbackManager.getReplaceInfoManager();
            varargout{2}=feedbackManager.getErrorManager();
        end


        function varargout=updateReplacePreview(varargin)
            import simulink.search.internal.SearchInstanceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            varargout{1}=[];
            searchManager=SearchInstanceManager.getSearchInstanceManager(studioTag);
            if isempty(searchManager)
                return;
            end
            replaceRegx=varargin{2};
            searchManager.updateReplaceRegx(replaceRegx);
            searchModel=searchManager.getSearchModel();
            if isempty(searchModel)
                return;
            end
            varargout{1}=searchModel.getPropertyInfo();
        end

        function stopReplace(varargin)
            import simulink.search.internal.SearchInstanceManager;
            studioTag=varargin{1};
            if isempty(studioTag)
                studioTag='';
            end
            searchManager=SearchInstanceManager.getSearchInstanceManager(studioTag);
            if isempty(searchManager)
                return;
            end
            searchManager.stopReplace();
        end
    end
end
