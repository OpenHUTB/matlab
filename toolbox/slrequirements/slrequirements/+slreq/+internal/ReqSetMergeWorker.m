classdef ReqSetMergeWorker<handle



    properties(Access=private)
        mfModelObj;
        thisFilename;
        reqData;
    end

    methods
        function this=ReqSetMergeWorker(fullFilename)
            this.thisFilename=fullFilename;
            this.reqData=slreq.data.ReqData.getInstance();
            this.mfModelObj=this.reqData.loadReqSetRaw(fullFilename);
            if~isempty(this.mfModelObj)
                this.mfModelObj.filepath=this.thisFilename;
            end
        end

        function delete(this)
            this.reset();
        end

        function this=reset(this)
            if~isempty(this.mfModelObj)
                this.mfModelObj.destroy();
            end
            this.mfModelObj=[];
            this.reqData=[];
            this.thisFilename='';
        end

        function this=save(this)
            this.mfModelObj.MATLABVersion=version;
            this.reqData.updateModificationInfo(this.mfModelObj);

            if this.mfModelObj.dirty

                if this.mfModelObj.revision>0||this.mfModelObj.items.Size>0
                    this.mfModelObj.revision=this.mfModelObj.revision+1;
                end
            end


            package=slreq.opc.Package(this.thisFilename);
            data=this.reqData.serialize(this.mfModelObj);
            package.save(data);
        end

        function done=removeRequirement(this,sid)
            done=false;
            mfReq=this.mfModelObj.items{int32(sid)};
            if~isempty(mfReq)
                mfReq.destroyContentsRecursively(true,true);

                this.mfModelObj.dirty=true;
                this.mfModelObj.updateHIdx();
                done=true;
            end
        end

        function done=copyRequirement(this,srcFullFilename,sid)
            done=false;
            if~isfile(srcFullFilename)

                return
            end


            mfThatModelObj=this.reqData.loadReqSetRaw(srcFullFilename);
            if isempty(mfThatModelObj)||~isvalid(mfThatModelObj)
                return
            end


            mfOrigReq=mfThatModelObj.items{int32(sid)};
            if isempty(mfOrigReq)||~isvalid(mfOrigReq)

                mfThatModelObj.destroy();
                return
            end


            mfOrigParent=mfOrigReq.parent;
            if isempty(mfOrigParent)
                mfOrigParent=mfOrigReq.requirementSet;
            end

            if isa(mfOrigParent,'slreq.datamodel.RequirementSet')
                mfDestParent=[];
            elseif isa(mfOrigParent,'slreq.datamodel.RequirementItem')
                mfDestParent=this.mfModelObj.items{mfOrigParent.sid};
            end

            this.copyRequirementTree(mfDestParent,mfOrigReq);

            this.mfModelObj.dirty=true;
            this.mfModelObj.updateHIdx();


            mfThatModelObj.destroy();
            done=true;
        end

        function copyRequirementTree(this,mfDestParent,mfOrigReq)


            mfDestReq=this.cloneRequirement(mfOrigReq);

            this.mfModelObj.items.add(mfDestReq);

            if~isempty(mfDestParent)
                mfDestReq.parent=mfDestParent;
            else
                this.mfModelObj.rootItems.add(mfDestReq);
            end

            mfOrigReqChildren=mfOrigReq.children.toArray;
            for n=1:length(mfOrigReqChildren)
                mfOrigReqChild=mfOrigReqChildren(n);
                this.copyRequirementTree(mfDestReq,mfOrigReqChild);
            end
        end

        function mfOutreq=cloneRequirement(this,mfInReq)
            reqInfo.id=mfInReq.customId;
            reqInfo.summary=mfInReq.summary;
            reqInfo.description=mfInReq.description;
            reqInfo.rationale=mfInReq.rationale;
            reqInfo.descriptionEditorType=mfInReq.descriptionEditorType;
            reqInfo.rationaleEditorType=mfInReq.rationaleEditorType;
            reqInfo.typeName=mfInReq.typeName;

            if isa(mfInReq,'slreq.datamodel.Justification')
                mfOutreq=this.reqData.createJustification(reqInfo);
            else
                mfOutreq=this.reqData.createRequirement(reqInfo);
            end

            mfOutreq.dirty=true;
            mfOutreq.sid=mfInReq.sid;
            mfOutreq.hIdx=mfInReq.hIdx;
            mfOutreq.revision=mfInReq.revision;
            mfOutreq.modifiedBy=mfInReq.modifiedBy;
            mfOutreq.modifiedOn=mfInReq.modifiedOn;
            mfOutreq.createdBy=mfInReq.createdBy;
            mfOutreq.createdOn=mfInReq.createdOn;


            mfInKeys=mfInReq.keywords.toArray;
            for n=1:length(mfInKeys)
                mfOutreq.keywords.add(mfInKeys{n});
            end


            mfInComments=mfInReq.comments.toArray;
            for n=1:length(mfInComments)
                mfOutreq.comments.add(mfInComments{n});
            end








        end
    end
end

