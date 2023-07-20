classdef RollupStatusManager<handle






    properties(SetAccess=private,GetAccess=private)

        ReqDataChangeListener;

        DataReqIDListForImplStatus={};
        DataReqIDListForVeriStatus={};
    end


    methods(Access=?slreq.app.MainManager)


        function this=RollupStatusManager()
            reqData=slreq.data.ReqData.getInstance();
            this.ReqDataChangeListener=reqData.addlistener('ReqDataChange',@this.onReqDataChange);
        end


        function delete(this)
            delete(this.ReqDataChangeListener);
            this.ReqDataChangeListener=[];
        end
    end

    methods(Access=private)

        function onReqDataChange(this,~,eventInfo)
            switch eventInfo.type
            case 'BeforeDeleteRequirement'
                eventData=eventInfo.eventObj;
                dataObjList=eventData.dataObjs;



                this.cacheReqIDsForRollupStatusWhenDeleteJustification(dataObjList);
            case 'Pre Requirement Deleted'






                slreq.analysis.BaseRollupAnalysis.refreshImplementationStatusForReqs(...
                this.getDataReqsFromFullID(this.DataReqIDListForImplStatus));
                slreq.analysis.BaseRollupAnalysis.refreshVerificationStatusForReqs(...
                this.getDataReqsFromFullID(this.DataReqIDListForVeriStatus));
                this.clearCachedReqIDs;
            end
        end


        function cacheReqIDsForRollupStatusWhenDeleteJustification(this,dataObjList)
            involvedLinks=slreq.data.Link.empty;
            for index=1:length(dataObjList)
                cDataObj=dataObjList{index};
                if isa(cDataObj,'slreq.data.Requirement')&&cDataObj.isJustification
                    [~,outLinks]=cDataObj.getLinks;
                    involvedLinks=[involvedLinks,outLinks];%#ok<AGROW>
                end
            end




            mgr=slreq.app.MainManager.getInstance;
            allViewers=mgr.getAllViewers;

            isRefreshImpl=mgr.isImplementationStatusEnabled(allViewers);
            isRefreshVeri=mgr.isVerificationStatusEnabled(allViewers);
            [dataReqsForImpl,dataReqsForVeri]=...
            slreq.analysis.BaseRollupAnalysis.getInvolvedReqs(...
            involvedLinks,isRefreshImpl,isRefreshVeri);

            this.DataReqIDListForImplStatus=this.getFullIDFromDataReqs(dataReqsForImpl);
            this.DataReqIDListForVeriStatus=this.getFullIDFromDataReqs(dataReqsForVeri);
        end


        function clearCachedReqIDs(this)
            this.DataReqIDListForImplStatus={};
            this.DataReqIDListForVeriStatus={};
        end


        function reqFullIDs=getFullIDFromDataReqs(~,dataReqs)
            reqFullIDs=cell(length(dataReqs),1);
            for index=1:length(dataReqs)
                reqFullIDs{index}=dataReqs(index).getFullID;
            end
        end


        function dataReqs=getDataReqsFromFullID(~,fullIDList)
            dataReqs=slreq.data.Requirement.empty;
            for index=1:length(fullIDList)
                dataReq=slreq.utils.getReqObjFromFullID(fullIDList{index});

                if~isempty(dataReq)
                    dataReqs(end+1)=dataReq;%#ok<AGROW>
                end
            end
        end
    end
end