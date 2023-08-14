function recCopyChildren(this,src,dstParent,action)
















    if isa(dstParent,'slreq.datamodel.RequirementSet')
        dstReqSet=dstParent;
    else
        dstReqSet=dstParent.requirementSet;
    end

    reqInfo.id=src.customId;
    reqInfo.summary=src.summary;
    reqInfo.description=src.description;
    reqInfo.rationale=src.rationale;
    reqInfo.descriptionEditorType=src.descriptionEditorType;
    reqInfo.rationaleEditorType=src.rationaleEditorType;
    if isa(src,'slreq.datamodel.Justification')
        dst=this.createJustification(reqInfo);
    elseif isa(src,'slreq.datamodel.ExternalRequirement')&&strcmpi(src.group.domain,'Stateflow:ReqTable')
        reqInfo.artifactId=src.artifactId;
        groupUri=src.group.artifactUri;
        domain=src.group.domain;
        group=this.getGroup(groupUri,domain,dstReqSet);
        reqInfo.group=group;
        dst=this.createExternalRequirement(reqInfo);
        group.items.add(dst);
    else
        dst=this.createRequirement(reqInfo);
    end


    srcKeys=src.keywords.toArray;
    for n=1:length(srcKeys)
        dst.keywords.add(srcKeys{n});
    end



    dst.typeName=src.typeName;

    if strcmp(action.type,'cut')
        src.requirementSet.dirty=true;
    elseif contains(action.type,'paste')
        dstReqSet.dirty=true;
    end

    if strcmp(action.type,'cut')


        dst.sid=src.sid;
        if src.references.Size>0



            fullSid=[src.requirementSet.name,'#',num2str(src.sid)];
            refs=src.references.toArray;
            this.cutReqLinkMap(fullSid)=[refs.link];
        end



        locCopyRevisionInfo(src,dst)
    elseif action.KeepSID&&(src.sid>0)


        dst.sid=src.sid;






        src.sid=-src.sid;
    elseif strcmp(dstReqSet.filepath,'clipboard.slreqx')


        dst.sid=src.sid;
    else

        dstReqSet.lastNumericID=dstReqSet.lastNumericID+1;
        dst.sid=dstReqSet.lastNumericID;
    end







    dstReqSet.items.add(dst);
    if strcmp(action.type,'paste')&&~action.KeepSID



        clipboard=this.getClipboardReqSet();
        [~,oldReqSetName]=fileparts(clipboard.getProperty('sourceReqSet'));
        newReqSetName=dstReqSet.name;
        if src.sid<0
            oldSid=-src.sid;
        else
            oldSid=src.sid;
        end
        newSid=dst.sid;

        dataReqSet=this.wrap(dstReqSet);
        dataReq=this.wrap(dst);

        if slreq.gui.ExternalEditor.isEditorTypeWord(dst,'Description')



            slreq.gui.ExternalEditor.copyImagesToNewDstFolder(dataReq,...
            oldReqSetName,oldSid,newReqSetName,newSid,'Description');
        elseif~strcmp(oldReqSetName,newReqSetName)






            dataReqSet.collectImagesFromHTML(dataReq.getRawDescription);
        else

        end

        if slreq.gui.ExternalEditor.isEditorTypeWord(dataReq,'Rationale')
            slreq.gui.ExternalEditor.copyImagesToNewDstFolder(dataReq,...
            oldReqSetName,oldSid,newReqSetName,newSid,'Rationale')
        elseif~strcmp(oldReqSetName,newReqSetName)



            dataReqSet.collectImagesFromHTML(dataReq.getRawRationale);
        else

        end
    end


    fullSID=[dst.requirementSet.name,'#',num2str(dst.sid)];
    if isKey(this.cutReqLinkMap,fullSID)

        links=this.cutReqLinkMap(fullSID);
        for n=1:length(links)
            links(n).dest.requirement=dst;
        end
        this.cutReqLinkMap.remove(fullSID);
    end


    if action.CopyAttributes
        this.copyCustomAttributes(src,dst,action.type)
    end




    if strcmp(action.type,'paste')||strcmp(action.type,'copy')

        if isfield(action,'KeepRevisionInfo')&&action.KeepRevisionInfo
            locCopyRevisionInfo(src,dst);
        else
            dst.createdOn=datetime('now','TimeZone','UTC');
            slreq.data.ReqData.updateModificationInfo(dst);
        end
    end

    if isa(dstParent,'slreq.datamodel.RequirementItem')
        dst.parent=dstParent;
    else
        if contains(action.type,'paste')

            rootItems=dstReqSet.rootItems.toArray;
            if~isempty(rootItems)&&isa(rootItems(end),'slreq.datamodel.Justification')

                dstReqSet.rootItems.insertAt(dst,dstReqSet.rootItems.Size);
            else
                dstReqSet.rootItems.add(dst);
            end
        else

            dstReqSet.rootItems.add(dst);
        end
    end


    ch=src.children.toArray;
    for n=1:length(ch)
        this.recCopyChildren(ch(n),dst,action);
    end
end


function locCopyRevisionInfo(src,dst)
    dst.createdBy=src.createdBy;
    dst.createdOn=src.createdOn;
    dst.modifiedBy=src.modifiedBy;
    dst.modifiedOn=src.modifiedOn;
    dst.revision=src.revision;
end
