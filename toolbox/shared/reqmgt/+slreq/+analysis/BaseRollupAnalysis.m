classdef BaseRollupAnalysis<handle





    properties(Constant,Hidden)

        implStatus=struct('total',0,'implemented',0,'justified',0,'none',0);
        implStatusCustom=struct('total',0,'implemented',0,'partiallyImplemented',0,'almostDone',0,'justStarted',0,'justified',0,'none',0);
        verifStatus=struct('total',0,'passed',0,'failed',0,'unexecuted',0,'justified',0,'none',0);
    end

    properties




        status=struct(...
        'Implementation',slreq.analysis.BaseRollupAnalysis.implStatus,...
        'Verification',slreq.analysis.BaseRollupAnalysis.verifStatus...
        );
        selfStatus=struct('Implementation',slreq.analysis.Status.Unset,...
        'Verification',slreq.analysis.Status.Unset);
    end

    methods
        function acceptVisitor(this,preVisitor,postVisitor)
            isInInformational=preVisitor.isInInformational;
            isHierarchicallyJustifiedForImplementation=preVisitor.isHierarchicallyJustifiedForImplementation;
            isHierarchicallyJustifiedForVerification=preVisitor.isHierarchicallyJustifiedForVerification;

            this.accept(preVisitor);

            children=this.children;
            for n=1:length(children)
                ch=children(n);
                ch.acceptVisitor(preVisitor,postVisitor);
            end



            if~preVisitor.isInInformational
                this.accept(postVisitor);
            end



            preVisitor.isInInformational=isInInformational;
            preVisitor.isHierarchicallyJustifiedForImplementation=isHierarchicallyJustifiedForImplementation;
            preVisitor.isHierarchicallyJustifiedForVerification=isHierarchicallyJustifiedForVerification;
        end

        function initImplementationStatus(this)

            if reqmgt('rmiFeature','CustomRollup')
                if isa(this,"slreq.data.RequirementSet")
                    customAttributes=this.CustomAttributeNames;
                elseif isa(this,"slreq.data.Requirement")
                    customAttributes=this.getReqSet().CustomAttributeNames;
                end
                hasImplementationStatus=any(cellfun(@(x)strcmp(x,'ImplementationStatus'),customAttributes));
                if(hasImplementationStatus)
                    this.status.Implementation=this.implStatusCustom;
                    this.selfStatus.Implementation=slreq.analysis.Status.Unset;
                end
                return;
            end
            this.status.Implementation=this.implStatus;
            this.selfStatus.Implementation=slreq.analysis.Status.Unset;
        end

        function initVerificationStatus(this)
            this.status.Verification=this.verifStatus;
            this.selfStatus.Verification=slreq.analysis.Status.Unset;
        end

        function status=getStatus(this,name,propName)
            status=this.status.(name).(propName);
        end

        function incrementStatus(this,name,propName)
            this.status.(name).(propName)=this.status.(name).(propName)+1;
        end

        function addStatus(this,name,propName,value)
            this.status.(name).(propName)=this.status.(name).(propName)+value;
        end

        function status=handlePublicAPICall(this,rollupTypeName,selfStatus)



            if nargin==2

                isSelfStatus=false;
            else
                switch lower(selfStatus)
                case 'self'
                    isSelfStatus=true;
                case 'all'
                    isSelfStatus=false;
                otherwise
                    error(message('Slvnv:slreq:InvalidInputForGetStatus'));
                end
            end
            if~isSelfStatus
                status=this.getStatusAsStructure(rollupTypeName);
            else
                if isa(this,'slreq.data.RequirementSet')
                    error(message('Slvnv:slreq:SelfStatusNotSupportedForReqSet'))
                end
                status=this.getSelfStatusAsStructure(rollupTypeName);
            end
        end


        function status=getImplementationStatus(this)

            stat=this.status.Implementation;
            status(1)=stat.total;
            status(2)=stat.implemented;
            status(3)=stat.justified;
            status(4)=stat.none;
        end


        function status=getVerificationStatus(this)

            stat=this.status.Verification;
            status(1)=stat.total;
            status(2)=stat.passed;
            status(3)=stat.justified;
            status(4)=stat.failed;
            status(5)=stat.unexecuted;
            status(6)=stat.none;
        end


        function runTests(this,selfStatus,filter)
            verifLinks=slreq.data.ResultManager.getHierarchicalLinksForRequirement(this,selfStatus);
            resultManager=slreq.data.ResultManager.getInstance();
            resultManager.runVerification(verifLinks,[],filter);
        end
    end

    methods(Access=private)

        function status=getStatusAsStructure(this,rollupTypeName)
            statusEnum=this.selfStatus.(rollupTypeName);
            errorIfStatusUnset(this,statusEnum,rollupTypeName);
            status=this.status.(rollupTypeName);
        end

        function status=getSelfStatusAsStructure(this,rollupTypeName)

            statusEnum=this.selfStatus.(rollupTypeName);
            errorIfStatusUnset(this,statusEnum,rollupTypeName);
            switch rollupTypeName
            case 'Implementation'
                if reqmgt('rmiFeature','CustomRollup')
                    if isa(this,"slreq.data.RequirementSet")
                        customAttributes=this.CustomAttributeNames;
                    elseif isa(this,"slreq.data.Requirement")
                        customAttributes=this.getReqSet().CustomAttributeNames;
                    end
                    hasImplementationStatus=any(cellfun(@(x)strcmp(x,'ImplementationStatus'),customAttributes));
                    if(hasImplementationStatus)
                        status=slreq.analysis.BaseRollupAnalysis.implStatusCustom;
                    end
                else
                    status=slreq.analysis.BaseRollupAnalysis.implStatus;
                end
            case 'Verification'
                status=slreq.analysis.BaseRollupAnalysis.verifStatus;
            otherwise
                assert(false,'Rollup type name should be specified')
            end

            status=rmfield(status,'total');

            fldName=statusEnum.getFiledName();
            if~(statusEnum==slreq.analysis.Status.Container||statusEnum==slreq.analysis.Status.Excluded)

                status.(fldName)=status.(fldName)+1;
            end
        end

        function errorIfStatusUnset(this,statusEnum,rollupTypeName)%#ok<INUSL>


            if statusEnum==slreq.analysis.Status.Unset
                if strcmp(rollupTypeName,'Implementation')
                    error(message('Slvnv:slreq:NeedUpdateImplStatus'))
                else
                    error(message('Slvnv:slreq:NeedUpdateVerifStatus'))
                end
            end
        end

    end

    methods(Static)



        function[dataReqsForImpl,dataReqsForVerif]=getInvolvedReqs(dataLinksOrSet,needRefreshImpl,needRefreshVerif)







            if isa(dataLinksOrSet,'slreq.data.LinkSet')
                checkLinkType=true;
                allDataLinks=dataLinksOrSet.getAllLinks;
            elseif isa(dataLinksOrSet,'slreq.data.Link')



                checkLinkType=false;
                allDataLinks=dataLinksOrSet;
            end

            dataReqsForImpl=slreq.data.Requirement.empty;
            dataReqsForVerif=slreq.data.Requirement.empty;



            dataReqsForImplMapByID=containers.Map('KeyType','char','ValueType','any');
            dataReqsForVeriMapByID=containers.Map('KeyType','char','ValueType','any');

            if needRefreshImpl
                for index=1:length(allDataLinks)
                    processInvolvedReqsFromLinkForImplementationStatus(allDataLinks(index),...
                    checkLinkType,dataReqsForImplMapByID)
                end
            end

            if needRefreshVerif
                for index=1:length(allDataLinks)
                    processInvolvedReqsFromLinkForVerificationStatus(allDataLinks(index),...
                    checkLinkType,dataReqsForVeriMapByID)
                end
            end

            if dataReqsForImplMapByID.Count>0
                dataReqsForImplList=dataReqsForImplMapByID.values;
                dataReqsForImpl=[dataReqsForImplList{:}];
            end

            if dataReqsForVeriMapByID.Count>0
                dataReqsForVerifList=dataReqsForVeriMapByID.values;
                dataReqsForVerif=[dataReqsForVerifList{:}];
            end

        end


        function refreshed=refreshRollupStatusForLinks(dataLinksOrLinkSet,needRefreshImpl,needRefreshVerif)








            refreshed=false;
            [implDataReqs,verifDataReqs]=...
            slreq.analysis.BaseRollupAnalysis.getInvolvedReqs(dataLinksOrLinkSet,needRefreshImpl,needRefreshVerif);

            if needRefreshImpl
                if~isempty(implDataReqs)
                    slreq.analysis.BaseRollupAnalysis.refreshImplementationStatusForReqs(implDataReqs);
                    refreshed=true;
                end

            end

            if needRefreshVerif
                if~isempty(verifDataReqs)
                    slreq.analysis.BaseRollupAnalysis.refreshVerificationStatusForReqs(verifDataReqs);
                    refreshed=true;
                end
            end
        end


        function refreshImplementationStatusForReqs(dataReqs)
            allDataReqsAffected=uniqueBasedOnAcnestor(dataReqs);
            for dataReq=allDataReqsAffected
                dataReq.updateImplementationStatus();
            end
        end


        function refreshVerificationStatusForReqs(dataReqs)
            allDataReqsAffected=uniqueBasedOnAcnestor(dataReqs);
            for dataReq=allDataReqsAffected
                dataReq.updateVerificationStatus();
            end
        end
    end
end


function out=uniqueBasedOnAcnestor(dataReqs)






    reqIndexToBeRemoved=false(size(dataReqs));
    removedUuid=containers.Map('keyType','char','ValueType','logical');
    for index1=1:length(dataReqs)
        dataReq1=dataReqs(index1);
        if~reqIndexToBeRemoved(index1)
            continue;
        end

        for index2=index1+1:length(dataReqs)
            dataReq2=dataReqs(index2);
            if isKey(removedUuid,dataReq2.getUuid)

                continue;
            end

            if dataReq1==dataReq2

                reqIndexToBeRemoved(index1)=true;
                removedUuid(dataReq1.getUuid)=true;
                break;
            end

            if slreq.data.ReqData.isAncestorOf(dataReq2,dataReq1)

                reqIndexToBeRemoved(index1)=true;
                removedUuid(dataReq1.getUuid)=true;
                break;
            end

            if slreq.data.ReqData.isAncestorOf(dataReq1,dataReq2)

                reqIndexToBeRemoved(index2)=true;
                removedUuid(dataReq2.getUuid)=true;
            end
        end
    end

    dataReqs(reqIndexToBeRemoved)=[];
    out=dataReqs;
end



function processInvolvedReqsFromLinkForImplementationStatus(dataLink,...
    checkLinkType,dataReqsForImplMapByID)
    if~isempty(dataLink.dest)&&...
        strcmp(dataLink.destDomain,'linktype_rmi_slreq')
        if checkLinkType
            isImplement=slreq.app.LinkTypeManager.isa(...
            dataLink.type,slreq.custom.LinkType.Implement,dataLink.getLinkSet());

            if isImplement
                dataReqsForImplMapByID(dataLink.dest.getUuid)=dataLink.dest;%#ok<NASGU>
            end
        else
            dataReqsForImplMapByID(dataLink.dest.getUuid)=dataLink.dest;%#ok<NASGU>
        end
    end
end




function processInvolvedReqsFromLinkForVerificationStatus(dataLink,checkLinkType,dataReqsForVeriMapByID)
    if~isempty(dataLink.dest)&&...
        strcmp(dataLink.destDomain,'linktype_rmi_slreq')
        if checkLinkType
            isVerify=slreq.app.LinkTypeManager.isa(...
            dataLink.type,slreq.custom.LinkType.Verify,dataLink.getLinkSet());

            if isVerify
                dataReqsForVeriMapByID(dataLink.dest.getUuid)=dataLink.dest;
            end
        else
            dataReqsForVeriMapByID(dataLink.dest.getUuid)=dataLink.dest;
        end
    end


    if~isempty(dataLink.source)&&...
        strcmp(dataLink.source.domain,'linktype_rmi_slreq')


        if dataLink.source.isValid
            if checkLinkType
                isConfirm=slreq.app.LinkTypeManager.isa(...
                dataLink.type,slreq.custom.LinkType.Confirm,dataLink.getLinkSet());

                if isConfirm
                    dataReq=slreq.utils.getReqObjFromSourceItem(dataLink.source);
                    dataReqsForVeriMapByID(dataReq.getUuid)=dataReq;%#ok<NASGU>
                end
            else
                dataReq=slreq.utils.getReqObjFromSourceItem(dataLink.source);
                dataReqsForVeriMapByID(dataReq.getUuid)=dataReq;%#ok<NASGU>
            end
        end
    end
end


