classdef LinkSetUpdateMgr<handle













    properties(Hidden)
currentCallerName
linksetsToUpdate
linksetsLoadReferencedReqsets
    end

    methods(Access=private)
        function this=LinkSetUpdateMgr()
            this.reset();
        end

        function reset(this)
            this.currentCallerName='';
            this.linksetsToUpdate=slreq.data.LinkSet.empty();
            this.linksetsLoadReferencedReqsets=[];
        end

        function queueForUpdate(this,dataLinkSet,loadReferencedReqsets)
            if contains(dataLinkSet.filepath,this.currentCallerName)

                return;
            elseif~any(this.linksetsToUpdate==dataLinkSet)

                this.linksetsToUpdate(end+1)=dataLinkSet;
                this.linksetsLoadReferencedReqsets(end+1)=loadReferencedReqsets;
            end
        end

        function hasUpdates=executePendingUpdates(this)
            hasUpdates=false;
            reqData=slreq.data.ReqData.getInstance();
            while~isempty(this.linksetsToUpdate)

                hasUpdates=hasUpdates|reqData.updateAllLinkDestinations(this.linksetsToUpdate(1),this.linksetsLoadReferencedReqsets(1));
                this.linksetsToUpdate(1)=[];
                this.linksetsLoadReferencedReqsets(1)=[];
            end
            this.currentCallerName='';
        end

    end

    methods(Static)
        function singleton=getInstance()
            persistent updateMgr
            if isempty(updateMgr)
                updateMgr=slreq.linkmgr.LinkSetUpdateMgr();
            end
            singleton=updateMgr;
        end

        function clear()

            slreq.linkmgr.LinkSetUpdateMgr.getInstance.reset();
        end
    end

    methods

        function hasUpdates=requestUpdate(this,dataLinkSet,isPostLoad,loadReferencedReqsets)
            if nargin<4

                loadReferencedReqsets=true;
            end
            if~isempty(this.currentCallerName)



                this.queueForUpdate(dataLinkSet,loadReferencedReqsets);
                hasUpdates=false;
            else




                if isPostLoad

                    this.currentCallerName=dataLinkSet.filepath;
                    this.linksetsToUpdate=slreq.data.LinkSet.empty();
                end





                reqData=slreq.data.ReqData.getInstance();
                hasUpdates=reqData.updateAllLinkDestinations(dataLinkSet,loadReferencedReqsets);
                if isPostLoad




                    this.executePendingUpdates();
                end
            end
        end

        function wasRemoved=removeFromQueue(this,dataLinkSet)
            wasRemoved=false;
            if~isempty(this.linksetsToUpdate)
                matched=(this.linksetsToUpdate==dataLinkSet);
                if any(matched)
                    this.linksetsToUpdate(matched)=[];
                    this.linksetsLoadReferencedReqsets(matched)=[];
                    wasRemoved=true;
                end
            end
        end
    end

end
