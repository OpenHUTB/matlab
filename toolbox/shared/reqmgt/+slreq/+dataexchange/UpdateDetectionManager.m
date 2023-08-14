classdef UpdateDetectionManager<handle




    methods(Access=private)
        function this=UpdateDetectionManager()
        end
    end

    methods
        function changed=detectByTimestamp(~,dataReq)
            changed=false;
            prevState=dataReq.getPendingUpdateStatus();
            adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(dataReq.domain);
            status=[];
            if isa(adapter,'slreq.adapters.ExternalDomainAdapter')
                status=adapter.checkAvailableUpdate(dataReq);
            end
            if prevState~=status
                dataReq.setPendingUpdateStatus(status);
                changed=true;
            end
        end

        function detected=checkUpdatesForAllArtifacts(this)
            detected=false;
            reqData=slreq.data.ReqData.getInstance();
            loadedReqSets=reqData.getLoadedReqSets;
            for nReqSet=1:length(loadedReqSets)
                topReqs=reqData.getRootItems(loadedReqSets(nReqSet));
                for n=1:length(topReqs)
                    dataReq=topReqs(n);
                    if dataReq.isImportRootItem()
                        hasUpdate=this.detectByTimestamp(dataReq);
                        detected=detected||hasUpdate;
                    end
                end
            end
        end
    end

    methods(Static)
        function this=getInstance()
            persistent instance;
            if isempty(instance)||~isvalid(instance)
                instance=slreq.dataexchange.UpdateDetectionManager();
            end
            this=instance;
        end
    end
end
