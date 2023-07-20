classdef Link<slreq.data.AttributeOwner&slreq.data.ReqLinkBase




    properties(Access=private)
        reqData;
    end

    properties(Dependent,GetAccess=public,SetAccess=private)
source
dest
destStruct
comments
connector
diagramConnector
    end

    properties(Dependent)
destUri
destId
destDomain
description
rationale
type
keywords
    end

    properties(Dependent,GetAccess=public,SetAccess={?slreq.analysis.ChangeTrackingVisitor})
        linkedSourceRevision;
        linkedSourceTimeStamp;
        linkedDestinationRevision;
        linkedDestinationTimeStamp;
    end

    properties(GetAccess=public,SetAccess=?slreq.analysis.ChangeTrackingVisitor)

        sourceChangeStatus=slreq.analysis.ChangeStatus.Undecided;
        destinationChangeStatus=slreq.analysis.ChangeStatus.Undecided;
        currentSourceRevision=slreq.utils.DefaultValues.getRevision();
        currentSourceTimeStamp=0;
        currentDestinationRevision=slreq.utils.DefaultValues.getRevision();
        currentDestinationTimeStamp=0;
    end


    properties(Dependent,GetAccess=public,SetAccess=private)
dirty
    end

    properties(Dependent,GetAccess=public,SetAccess=?slreq.data.ReqData)
sid
    end

    properties(Constant)
        verification_mask_types={...
'Design Verifier Proof Objective'...
        ,'Checks_SMin'...
        ,'Checks_SMax'...
        ,'Checks_SRange'...
        ,'Checks_SGap'...
        ,'Checks_DMin'...
        ,'Checks_DMax'...
        ,'Checks_DRange'...
        ,'Checks_DGap'...
        ,'Checks_Gradient'...
        ,'Checks_Resolution'...
        };
    end

    methods(Access=?slreq.data.ReqData)



        function this=Link(modelObject)
            this.modelObject=modelObject;

            this.dirty=false;
            this.reqData=slreq.data.ReqData.getInstance();
        end
    end

    methods
        function setFilterState(this,fState)
            this.filterState=fState;
        end

        function accept(this,visitor)
            visitor.visitLink(this);
        end

        function out=get.linkedSourceRevision(this)
            out=this.modelObject.linkedVersion;
        end


        function out=get.linkedSourceTimeStamp(this)
            out=this.modelObject.getLinkedPTime();
        end


        function set.linkedSourceRevision(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.linkedVersion=value;
            this.setDirty(true);






        end


        function set.linkedSourceTimeStamp(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            this.modelObject.linkedTime=slreq.utils.getDateTime(value,'Write');
            this.setDirty(true);






        end


        function out=get.linkedDestinationRevision(this)
            out=this.modelObject.dest.linkedVersion;
        end


        function set.linkedDestinationRevision(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.dest.linkedVersion=value;
            this.setDirty(true);







        end


        function out=get.linkedDestinationTimeStamp(this)
            out=this.modelObject.dest.getLinkedPTime();
        end


        function set.linkedDestinationTimeStamp(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            this.modelObject.dest.linkedTime=slreq.utils.getDateTime(value,'Write');
            this.setDirty(true);






        end

        function value=get.keywords(this)
            if this.modelObject.keywords.Size>0
                value=this.modelObject.keywords.toArray;
            else
                value={};
            end
        end

        function set.keywords(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            slreq.data.ReqData.getInstance.setKeywords(this,value);
            this.setDirty(true);
            this.notifyObservers();
        end

        function set.type(this,typeNameOrEnum)
            if~this.checkLicense(this.source.artifactUri)
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            changedInfo.propName='type';
            changedInfo.oldValue=this.modelObject.typeName;

            if isenum(typeNameOrEnum)
                newTypeName=char(typeNameOrEnum);
            else
                newTypeName=typeNameOrEnum;
            end
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(this.getLinkSet(),newTypeName);

            if~isStereotype
                mfLinkType=this.reqData.getLinkType(typeNameOrEnum);
                newTypeName=mfLinkType.typeName;
            end
            if isequal(this.modelObject.typeName,newTypeName)
                return;
            end
            this.modelObject.typeName=newTypeName;
            this.setDirty(true);
            changedInfo.newValue=newTypeName;
            if~isempty(changedInfo.oldValue)



                this.notifyObservers(changedInfo);
            end
        end

        function value=get.type(this)
            value=this.modelObject.typeName;
        end

        function set.description(this,value)




            if isequal(this.description,value)
                return;
            end

            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end

            this.modelObject.description=value;
            this.setDirty(true);
            this.notifyObservers();
        end

        function value=get.description(this)
            value=this.modelObject.description;
            if contains(value,'_SELF')
                [~,artName]=fileparts(this.modelObject.source.artifact.artifactUri);
                value=strrep(value,'_SELF',artName);
            end
        end

        function value=getStoredDescription(this)

            value=this.modelObject.description;
        end

        function set.rationale(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end


            if isequal(this.modelObject.rationale,value)
                return;
            end

            this.modelObject.rationale=value;
            this.setDirty(true);
            this.notifyObservers();
        end

        function value=get.rationale(this)
            value=this.modelObject.rationale;
        end

        function set.destDomain(this,value)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.dest.domain=value;
            this.setDirty(true);
            this.notifyObservers();
        end
        function value=get.destDomain(this)
            value=this.modelObject.dest.domain;
        end

        function set.destUri(this,value)



            if~this.isSelf(value)&&~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end


            mfLinkDest=this.modelObject.dest;
            oldValue=mfLinkDest.artifactUri;


            mfLinkDest.artifactUri=value;


            if strcmp(this.destDomain,'linktype_rmi_slreq')

                [~,oldShortName,~]=fileparts(oldValue);
                [~,newShortName,~]=fileparts(value);
                mfLinkDest.reqSetUri=strrep(mfLinkDest.reqSetUri,oldShortName,newShortName);
            else





                mfLinkDest.reqSetUri='';
            end

            this.setDirty(true);
            this.notifyObservers();
        end

        function value=get.destUri(this)
            value=this.modelObject.dest.artifactUri;
            if contains(value,'_SELF')
                [~,artName,artExt]=fileparts(this.modelObject.source.artifact.artifactUri);
                value=[artName,artExt];
            end
        end

        function value=getStoredDestUri(this)


            value=this.modelObject.dest.artifactUri;
        end

        function set.destId(this,value)






            if~this.isSelf(this.modelObject.dest.artifactUri)&&~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.modelObject.dest.artifactId=value;
            this.setDirty(true);
            this.notifyObservers();
        end
        function value=get.destId(this)
            value=this.modelObject.dest.artifactId;
        end

        function sourceItem=get.source(this)
            sourceItem=slreq.data.ReqData.getWrappedObj(this.modelObject.source);
        end

        function dest=get.dest(this)
            dest=slreq.data.ReqData.getInstance.getTargetRequirement(this);
        end

        function sid=get.sid(this)
            sid=this.modelObject.sid;
        end

        function connector=get.connector(this)
            conn=this.modelObject.connector;
            if~isempty(conn)
                connector=slreq.data.ReqData.getWrappedObj(conn);
            else
                connector=slreq.data.Connector.empty;
            end
        end

        function connector=get.diagramConnector(this)
            connector=slreq.data.Connector.empty;
            conn=this.modelObject.diagramConnector;
            if~isempty(conn)
                connector=slreq.data.ReqData.getWrappedObj(conn);
            end
        end

        function out=get.dirty(this)
            out=this.modelObject.dirty;
        end

        function set.dirty(this,value)
            this.modelObject.dirty=value;
        end

        function linkSet=getLinkSet(this)
            linkSet=slreq.data.ReqData.getWrappedObj(this.modelObject.source.artifact);
        end

        function linkSet=getSet(this)
            linkSet=slreq.data.ReqData.getWrappedObj(this.modelObject.source.artifact);
        end

        function remove(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            linkSet=this.getLinkSet();
            linkSet.removeLink(this);
        end

        function[refUri,refDomain,refId]=getReferenceInfo(this)
            refUri=this.destUri;
            refDomain=this.destDomain;
            refId=this.destId;
        end

        function out=getReferenceFullName(this)


            out=[this.destUri,'#',this.destId];
        end

        function out=getFullID(this)


            dataLinkSet=this.getLinkSet;
            out=[dataLinkSet.name,':#',num2str(this.sid)];
        end

        function tf=isDirectLink(this)




            tf=isempty(this.modelObject.dest.reqSetUri);
        end

        function value=get.comments(this)
            value=[];

            revObj=this.modelObject.comments.toArray;
            for n=1:length(revObj)
                c=slreq.data.ReqData.getWrappedObj(revObj(n));
                if n==1
                    value=c;
                else
                    value(n)=c;%#ok<AGROW>
                end
            end
        end

        function comment=addComment(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            comment=this.reqData.addComment(this);
        end

        function removeComment(this,idx)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            toRemove=this.comments(idx);
            this.reqData.removeComment(toRemove);
            this.comments(idx)=[];
        end

        function connector=addConnector(this,isDiagram)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end


            connector=this.reqData.addConnector(this,isDiagram);


            hasExistingMarkup=connector.resolveExistingMarkup();
            if~hasExistingMarkup
                connector.addMarkup();
            end
        end

        function removeAllConnectors(this)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            this.reqData.removeConnectors(this.diagramConnector);
            this.reqData.removeConnectors(this.connector);
        end

        function removeConnector(this,isDiagram)
            if~this.checkLicense()
                error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
            end
            if isDiagram
                this.reqData.removeConnectors(this.diagramConnector);
            else
                this.reqData.removeConnectors(this.connector);
            end
        end

        function conn=getConnector(this,isDiagram)
            if isDiagram
                conn=this.diagramConnector;
            else
                conn=this.connector;
            end
        end

        function name=getForwardTypeName(this)
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(this.getLinkSet(),this.type);
            if isStereotype
                name=slreq.internal.ProfileLinkType.getForwardName(this);
            else
                name=slreq.app.LinkTypeManager.getForwardName(this.modelObject.typeName);
            end
        end

        function name=getBackwardTypeName(this)
            isStereotype=slreq.internal.ProfileLinkType.isProfileStereotype(this.getLinkSet(),this.type);
            if isStereotype
                name=slreq.internal.ProfileLinkType.getBackwardName(this);
            else
                name=slreq.app.LinkTypeManager.getBackwardName(this.modelObject.typeName);
            end
        end

        function setLinkTypeByForwardName(this,forwardName)
            allMFLinkTypes=slreq.data.ReqData.getInstance.getAllLinkTypes();
            for n=1:length(allMFLinkTypes)
                mfLinkType=allMFLinkTypes(n);

                thisForwardName=slreq.app.LinkTypeManager.getForwardName(mfLinkType.typeName);
                if strcmp(thisForwardName,forwardName)
                    this.type=mfLinkType.typeName;
                    return;
                end
            end

            linkType=slreq.internal.ProfileLinkType.getTypeByForwardName(this,forwardName);
            if~isempty(linkType)
                this.type=linkType;
                return;
            end
            assert(false,'Invalid forward link type name specified')
        end

        function tf=isBacklinkSupported(this)
            tf=false;
            if slreq.utils.isDomainWithBacklinks(this.destDomain)

                tf=true;
            elseif strcmp(this.destDomain,'linktype_rmi_slreq')

                linkDest=this.dest;
                if isempty(linkDest)

                    error(message('Slvnv:reqmgt:full_path:UnresolvedPath',this.destUri));
                elseif linkDest.external
                    if slreq.utils.isDomainWithBacklinks(linkDest.domain)
                        tf=true;
                    else

                        tf=linkDest.isOSLC();
                    end
                end
            end
        end

        function[hasBacklink,targetInfo]=checkBacklink(this)
            targetInfo=this.getExternalTargetInfo();
            domainType=rmi.linktype_mgr('resolveByRegName',targetInfo.domain);
            mwSource=this.source.artifactUri;
            mwId=this.source.id;
            [hasBacklink,reqInfo]=domainType.BacklinkCheckFcn(mwSource,mwId,targetInfo.doc,targetInfo.id);
            if isempty(reqInfo)
                error(message('Slvnv:reqmgt:NotFoundIn',targetInfo.id,targetInfo.doc));
            end
        end

        function isAdded=insertBacklink(this)
            targetInfo=this.getExternalTargetInfo();
            domainType=rmi.linktype_mgr('resolveByRegName',targetInfo.domain);
            mwSource=this.source.artifactUri;
            mwId=this.source.id;
            mwDomain=this.source.domain;
            try
                navcmd=domainType.BacklinkInsertFcn(targetInfo.doc,targetInfo.id,mwSource,mwId,mwDomain);
            catch ex
                title=getString(message('Slvnv:slreq_backlinks:FailedToAddBacklink'));
                mwShortName=slreq.uri.getShortNameExt(mwSource);
                msgText1=getString(message('Slvnv:slreq_backlinks:FailedToAddBacklinkFromTo',targetInfo.id,[mwShortName,mwId]));
                if strcmp(ex.identifier,'Simulink:utility:objectDestroyed')

                    msgText2=getString(message('Slvnv:slreq_backlinks:FailedToAddBacklinkReasonSL',[mwShortName,mwId]));
                else




                    msgText2=getString(message('Slvnv:slreq_backlinks:FailedToAddBacklinkReasonOther',ex.message));
                end
                errordlg({msgText1,msgText2},title);
                isAdded=false;
                return;
            end
            isAdded=~isempty(navcmd);
        end

        function updateSource(this,newSrcStruct)

            this.reqData.updateLinkSource(this,newSrcStruct);
        end

        function updateDestination(this,newDestStruct)


            if strcmp(newDestStruct.domain,'linktype_rmi_slreq')&&isfield(newDestStruct,'sid')
                newDestStruct.id=sprintf('#%d',newDestStruct.sid);
            end
            this.reqData.updateLinkDestination(this,newDestStruct);
        end

        function[adapter,artifactUri,artifactId]=getSrcAdapter(this)
            src=this.source;
            [adapter,artifactUri,artifactId]=src.getAdapter();
        end

        function[adapter,artifactUri,artifactId]=getDestAdapter(this)
            if~this.isDirectLink
                dom='linktype_rmi_slreq';
            else
                dom=this.destDomain;
            end
            adapter=slreq.adapters.AdapterManager.getInstance().getAdapterByDomain(dom);
            destReq=this.dest;
            if isempty(destReq)

                artifactUri=this.destUri;
                artifactId=this.destId;
            else
                artifactUri=adapter.getArtifactUri(destReq);
                artifactId=adapter.getArtifactId(destReq);
            end
        end

        function[icon,summary,tooltip]=getSrcIconSummaryTooltip(this)
            [adapter,artifactUri,artifactId]=this.getSrcAdapter();
            [icon,summary,tooltip]=adapter.getIconSummaryTooltipFromSourceItem(this.source,artifactUri,artifactId);
        end

        function[icon,summary,tooltip]=getDestIconSummaryTooltip(this)
            [adapter,artifactUri,artifactId]=this.getDestAdapter();
            [icon,summary,tooltip]=adapter.getIconSummaryTooltipFromReq(this.dest,artifactUri,artifactId);
            if~isempty(this.description)&&contains(summary,'...')


                if length(this.description)>40
                    summary=[this.description,'...'];
                else
                    summary=this.description;
                end
            end
        end

        function tf=isDestResolved(this)
            destReq=this.dest;
            if isempty(destReq)
                tf=false;
            elseif strcmp(destReq.domain,'linktype_rmi_slreq')

                tf=true;
            else
                [destAdapter,artifactUri,artifactId]=this.getDestAdapter();
                tf=destAdapter.isResolved(artifactUri,artifactId);
            end
        end

        function tf=isSrcResolved(this)
            [srcAdapter,artifactUri,artifactId]=this.getSrcAdapter();
            tf=srcAdapter.isResolved(artifactUri,artifactId);
        end

        function destStruct=get.destStruct(this)
            destStruct=struct('domain',this.destDomain,...
            'artifactUri',this.destUri,'id',this.destId);
        end

        function[tf,destinationDomain]=isExternalVerificationLink(this)

            tf=false;
            destinationDomain='';
            if~reqmgt('rmiFeature','ExtVerif')
                return;
            end




            if strcmp(this.source.domain,'linktype_rmi_slreq')
                destination=this.dest;
                if isempty(destination)
                    return;
                end
                destinationDomain=destination.domain;
                linkTypeObj=rmi.linktype_mgr('resolveByRegName',destinationDomain);
                if~isempty(linkTypeObj)&&~isempty(linkTypeObj.GetResultFcn)
                    tf=true;
                end
            end

        end


        function[affectImplementationStatus,affectVerificationStatus]=doesChangeImpactRollupStatus(this,changedEvent)
            propName=changedEvent.PropName;
            affectImplementationStatus=false;
            affectVerificationStatus=false;

            switch propName
            case 'type'
                linkSet=this.getLinkSet();
                oldType=changedEvent.OldValue;
                newType=changedEvent.NewValue;
                affectImplementationStatus=slreq.app.LinkTypeManager.affectImplementationStatus(linkSet,oldType,newType);
                affectVerificationStatus=slreq.app.LinkTypeManager.affectVerificationStatus(linkSet,oldType,newType);
                return;
            otherwise
                return;
            end
        end

        function label=getDisplayLabel(this,max_length)
            label=this.description;
            if isempty(label)
                label=this.getDefaultLabel();
            elseif nargin>1&&length(label)>max_length
                label=[label(1:max_length-5),'...'];
            end
        end

        function defaultLabel=getDefaultLabel(this)
            defaultLabel=sprintf('link #%d',this.sid);
        end

        function label=getLinkLabel(this)

            if~this.isDirectLink()

                destAdapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain('linktype_rmi_slreq');
                label=destAdapter.getSummary(this.destUri,this.destId);
            else

                label=this.description;
            end
        end
    end

    methods(Static)
        function tf=isDefaultDisplayLabel(label)


            tf=~isempty(regexp(label,'^link #\d+$','once'));
        end
    end

    methods(Access={?slreq.data.LinkSet,?slreq.data.ReqData,?slreq.data.ReqLinkBase})

        function setDirty(this,value)


            if value
                this.updateModificationInfo();
            end
            if this.dirty~=value
                this.dirty=value;
                if value
                    linkSet=this.getLinkSet();
                    linkSet.setDirty(true);
                end
            end
        end

    end

    methods(Access=private)

        function tf=isSelf(this,destUri)
            if contains(destUri,'_SELF')
                tf=true;
            elseif contains(this.source.artifactUri,destUri)
                tf=true;
            else
                tf=false;
            end
        end

        function targetInfo=getExternalTargetInfo(this)


            targetInfo.domain=this.destDomain;
            if strcmp(this.destDomain,'linktype_rmi_slreq')
                if~isempty(this.dest)
                    linkDest=this.dest;

                    assert(linkDest.external,'link destination is not an external requirement');

                    targetInfo.doc=linkDest.artifactUri;
                    targetInfo.id=linkDest.artifactId;
                    if linkDest.isOSLC()

                        targetInfo.domain='linktype_rmi_oslc';
                    else
                        targetInfo.domain=linkDest.domain;
                    end
                    linkSourcePath=this.dest.getReqSet.filepath;
                else


                    error(message('Slvnv:reqmgt:full_path:UnresolvedPath',this.destUri));
                end
            else
                targetInfo.doc=this.destUri;
                targetInfo.id=this.destId;
                linkSourcePath=this.source.artifactUri;
            end










            targetInfo.doc=slreq.uri.getUniqueDocID(targetInfo.doc,targetInfo.domain,linkSourcePath);

        end

    end

    methods(Access=?slreq.data.ReqData)

        function setDefaultLinkType(this)

            if this.isExternalVerificationLink()
                this.type=slreq.custom.LinkType.Confirm;
            else
                [adapter,artifact,id]=this.getSrcAdapter();
                this.type=adapter.getDefaultLinkType(artifact,id);
            end
        end

    end
end

