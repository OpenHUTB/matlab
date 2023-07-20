classdef Connector<slreq.data.AttributeOwner










    properties(Dependent,GetAccess=public,SetAccess=public)
        isGroundLink;
        isVisible;
        markup;
    end

    properties(GetAccess=private,SetAccess=private)
        reqData;
    end

    methods(Access=?slreq.data.ReqData)



        function this=Connector(modelObject)
            this.modelObject=modelObject;
            this.reqData=slreq.data.ReqData.getInstance;
        end
    end

    methods

        function isGroundLink=get.isGroundLink(this)
            if isempty(this.modelObject.link)
                isGroundLink=true;
            else
                isGroundLink=false;
            end
        end

        function tf=get.isVisible(this)
            tf=this.modelObject.isVisible;
        end

        function set.isVisible(this,val)
            if this.modelObject.isVisible~=val
                this.modelObject.isVisible=val;
                if this.modelObject.markup.linkSet.dirty

                    this.getLinkSet.setDirty(true);
                end
            end
        end

        function mkup=get.markup(this)
            mkup=slreq.data.Markup.empty;
            if~isempty(this.modelObject.markup)
                mkup=this.reqData.findObject(this.modelObject.markup.UUID);
            end
        end

        function parentSID=getViewOwnerID(this)



            parentSID='';
            link=this.getLink;
            source=link.source;

            [~,mdlName,~]=fileparts(source.artifactUri);
            zcElem=[];
            if Simulink.internal.isArchitectureModel(mdlName,'Architecture')||...
                Simulink.internal.isArchitectureModel(mdlName,'SoftwareArchitecture')
                zcElem=sysarch.resolveZCElement(source.id,mdlName);
            end
            if~isempty(zcElem)
                if sysarch.isZCPort(zcElem)
                    srcSID=source.id;
                    objInfo=sysarch.getPortHandleForMarkup(source.id,mdlName);
                    parent=get_param(get_param(objInfo,'Parent'),'Parent');
                    parentFullSID=Simulink.ID.getSID(parent);
                end
            else
                srcSID=link.source.getSID;
                if this.isGroundLink
                    parentFullSID=srcSID;
                else

                    if rmisl.isHarnessIdString(srcSID)
                        [~,objH]=rmisl.resolveObjInHarness(srcSID);
                        parentFullSID=get(objH,'Parent');
                    else
                        parentFullSID=Simulink.ID.getParent(srcSID);
                    end
                end

                objInfo=Simulink.ID.getHandle(srcSID);
            end
            if isa(objInfo,'Stateflow.Transition')
                [transInfo,viewerInfo]=slreq.utils.getTransitionViewerList(objInfo.Id);
                if~isempty(transInfo)
                    sr=sfroot;
                    if this.isGroundLink


                        parentFullSID=Simulink.ID.getSID(sr.idToHandle(viewerInfo.topViewerID));
                    else
                        parentFullSID=Simulink.ID.getSID(sr.idToHandle(viewerInfo.sourceViewerID));
                    end
                end
            end

            if~isempty(parentFullSID)
                colPos=strfind(parentFullSID,':');
                if~isempty(colPos)
                    parentSID=parentFullSID(colPos(1):end);
                end
            end
        end

        function link=getLink(this)
            if~isempty(this.modelObject.link)
                uuid=this.modelObject.link.UUID;
            else
                uuid=this.modelObject.diagramLink.UUID;
            end
            link=this.reqData.findObject(uuid);
        end

        function linkSet=getLinkSet(this)
            uuid=this.modelObject.markup.linkSet.UUID;
            linkSet=this.reqData.findObject(uuid);
        end

        function resolved=resolveExistingMarkup(this)
            linkSet=this.getLink.getLinkSet;
            thisviewOwenerId=this.getViewOwnerID;
            thisSourceObjId=this.getLink.getReferenceFullName;
            resolved=this.reqData.resolveExistingMarkup(linkSet,this,thisviewOwenerId,thisSourceObjId);
        end
    end

    methods(Access=?slreq.data.Link)
        function addMarkup(this)
            mkup=this.reqData.addMarkup(this);
            mkup.viewOwnerId=this.getViewOwnerID();
            mkup.sourceObjId=this.getLink.getReferenceFullName;
        end
    end
end


