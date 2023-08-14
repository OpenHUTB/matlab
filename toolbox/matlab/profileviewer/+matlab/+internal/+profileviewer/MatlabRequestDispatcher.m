classdef MatlabRequestDispatcher<matlab.internal.profileviewer.AbstractRequestDispatcher




    methods
        function obj=MatlabRequestDispatcher(dataModel,profilerState)
            assert(isa(dataModel,'matlab.internal.profileviewer.model.MatlabDataModel'));
            obj@matlab.internal.profileviewer.AbstractRequestDispatcher(dataModel,profilerState,matlab.internal.profileviewer.ProfilerType.MATLAB);

            obj.addPayloadRequestDispatchers({'FlamegraphViewPayload',...
            'RunAndTimeHistory',...
            'RunAndTimePayload',...
            'RunAndTimeErrorPayload'},...
            {@(data)obj.executePayloadRequestCallback(data,@obj.getFlamegraphViewPayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getRunAndTimeHistory),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getLastRunAndTimePayload),...
            @(data)obj.executePayloadRequestCallback(data,@obj.getLastRunAndTimeErrorPayload)});

            obj.addCustomRequestDispatchers({'setRunAndTimeHistory'},...
            {@(data)obj.executeCustomRequestCallback(data,@obj.setRunAndTimeHistory)});
            mlock;
        end
    end

    methods(Hidden)
        function payload=getFlamegraphViewPayload(obj,~)
            payload=obj.DataModel.getFlamegraphViewPayload();
        end

        function payload=getLandingViewPayload(obj,~)
            payload=obj.DataModel.getLandingViewPayload();
        end

        function payload=getSummaryTitlePayload(obj,~)
            payload=obj.DataModel.getSummaryTitlePayload();
        end

        function payload=getSummaryViewPayload(obj,~)
            payload=obj.DataModel.getSummaryViewPayload();
        end

        function payload=getDetailTitlePayload(obj,requestData)
            payload=obj.DataModel.getDetailTitlePayload(requestData.functionIndex);
        end

        function payload=getProfileStatusPayload(obj,~)
            payload=obj.DataModel.getProfileStatusPayload();
        end

        function payload=getDetailViewPayload(obj,requestData)
            payload=obj.DataModel.getDetailViewPayload(requestData.functionIndex);
        end


        function lastRunAndTimeExpression=getLastRunAndTimePayload(obj,~)
            lastRunAndTimeExpression=obj.DataModel.getLastRunAndTimePayload();
        end

        function lastRunAndTimeError=getLastRunAndTimeErrorPayload(obj,~)
            lastRunAndTimeError=obj.DataModel.getLastRunAndTimeErrorPayload();
        end

        function historyData=getRunAndTimeHistory(obj,~)
            historyData=obj.DataModel.getRunAndTimeHistory();
        end

        function setRunAndTimeHistory(obj,requestData)
            obj.DataModel.setRunAndTimeHistory(requestData.payload);
        end

        function handleComparisonWindowLaunch(obj,data)

            summaryViewPayload=obj.DataModel.getSummaryViewPayload();
            profileHtmlText=matlab.internal.profileviewer.profview(data.functionIndex,summaryViewPayload);
            matlab.internal.profileviewer.stripanchors(profileHtmlText);
        end
    end
end
