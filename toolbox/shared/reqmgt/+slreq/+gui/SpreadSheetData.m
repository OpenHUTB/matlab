classdef SpreadSheetData<handle




    properties
        modelH;
        reqRoot;
        linkRoot;
        dasLinkSet=slreq.das.LinkSet.empty;
        isReqView;
        reqColumns=slreq.app.MainManager.DefaultRequirementColumns;
        linkColumns=slreq.app.MainManager.DefaultLinkColumns;
        reqSortInfo=struct('Col','','Order',false);
        linkSortInfo=struct('Col','','Order',false);
        displayVerificationStatus=false;
        displayImplementationStatus=false;
        displayChangeInformation=true;

    end

    properties(Dependent)
        sourceID;
    end

    methods

        function this=SpreadSheetData(modelH)




            this.modelH=modelH;

            this.reqRoot=slreq.das.BaseObject;
            this.linkRoot=slreq.das.BaseObject;



            this.updateDisplayedReqSet();



        end


        function delete(this)





...
...
...
...
...
...
...
...


            this.modelH=[];
            this.reqRoot=[];
            this.linkRoot=[];

        end


        function clearDasLinkSet(this)
            this.reqRoot=slreq.das.BaseObject;
            this.linkRoot=slreq.das.BaseObject;
            this.dasLinkSet=[];
        end


        function out=getColumns(this,isReqView)
            if nargin<2
                isReqView=this.isReqView;
            end
            if isReqView
                out=this.reqColumns;
            else
                out=this.linkColumns;
            end
        end


        function out=get.sourceID(this)
            try

                out=get_param(this.modelH,'Name');
            catch ME %#ok<NASGU>

                out='';
            end
        end


        function out=getSortInfo(this,isReqView)
            if nargin<2
                isReqView=this.isReqView;
            end
            if isReqView
                out=this.reqSortInfo;
            else
                out=this.linkSortInfo;
            end
        end



        function[tf,root]=isReqOrLinkSetRegistered(this,targetObj)
            tf=false;


            if isa(targetObj,'slreq.data.RequirementSet')
                dasObj=targetObj.getDasObject();
                root=this.reqRoot;
            elseif isa(targetObj,'slreq.das.RequirementSet')
                dasObj=targetObj;
                root=this.reqRoot;
            elseif isa(targetObj,'slreq.data.LinkSet')
                dasObj=targetObj.getDasObject();
                root=this.linkRoot;
            elseif isa(targetObj,'slreq.das.LinkSet')
                dasObj=targetObj;
                root=this.linkRoot;
            else
                error('Internal error: Invalid object specified')
            end
            for n=1:length(root.children)
                if root.children(n)==dasObj

                    tf=true;
                    return;
                end
            end
        end


        function removedIndex=removeReqLinkSet(this,thisReqLinkSetObj)
            if isa(thisReqLinkSetObj,'slreq.das.RequirementSet')
                rootObj=this.reqRoot;
            elseif isa(thisReqLinkSetObj,'slreq.das.LinkSet')
                rootObj=this.linkRoot;
            else

                return;
            end




            removedIndex=0;
            for n=1:length(rootObj.children)
                if thisReqLinkSetObj==rootObj.children(n)
                    rootObj.children(n)=[];




                    removedIndex=n;
                    break;
                end
            end


        end


        function displayAssociatedLinkSet(this)
            if isempty(this.dasLinkSet)||~isvalid(this.dasLinkSet)
                r=slreq.data.ReqData.getInstance;
                lSet=r.getLinkSet(get_param(this.modelH,'FileName'));
                if isempty(lSet)
                    this.dasLinkSet=slreq.das.LinkSet.empty;
                else
                    this.dasLinkSet=lSet.getDasObject();














                    if~isempty(this.dasLinkSet)
                        this.addReqLinkSet(this.dasLinkSet);
                    end
                end
            end


            if isempty(this.linkRoot.children)
                this.addReqLinkSet(this.dasLinkSet);
            end
        end


        function addReqLinkSet(this,reqLinkSetDas)


            if isempty(reqLinkSetDas)||~isvalid(reqLinkSetDas)
                return;
            end

            [isVisible,root]=this.isReqOrLinkSetRegistered(reqLinkSetDas);
            if~isVisible
                if isempty(root.children)
                    root.children=reqLinkSetDas;
                else
                    root.children(end+1)=reqLinkSetDas;
                end

            end
        end


        function updateDisplayedReqSet(this)
            this.displayAssociatedLinkSet();

            reqData=slreq.data.ReqData.getInstance();
            if~isempty(this.dasLinkSet)
                rSetFiles=this.dasLinkSet.getRegisteredRequirementSets();

                for n=1:length(rSetFiles)
                    dataReqSet=reqData.getReqSet(rSetFiles{n});
                    if~isempty(dataReqSet)...
                        &&~this.isReqOrLinkSetRegistered(dataReqSet)
                        dasReqSet=dataReqSet.getDasObject();

                        if~isempty(dasReqSet)













                            this.addReqLinkSet(dasReqSet);
                        end
                    end
                end
            end
            allReqSets=reqData.getLoadedReqSets;
            for n=1:length(allReqSets)
                dasReqSet=allReqSets(n).getDasObject;
                if isa(dasReqSet,'slreq.das.ReqSetInSL')
                    if this.modelH==get(dasReqSet.modelObj,'Handle')
                        this.addReqLinkSet(dasReqSet);
                    end
                end
            end
        end


        function setSortInfo(this,col,order,isReqView)
            if nargin<4
                isReqView=this.sReqView;
            end
            if isReqView
                this.reqSortInfo.Col=col;
                this.reqSortInfo.Order=order;
            else
                this.linkSortInfo.Col=col;
                this.linkSortInfo.Order=order;
            end
        end
    end
end