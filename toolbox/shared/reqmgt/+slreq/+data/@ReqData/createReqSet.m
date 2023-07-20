function reqSetObj=createReqSet(this,name)






    if~slreq.data.DataModelObj.checkLicense()
        error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
    end

    if nargin==1||isempty(name)
        name=this.getDefaultReqSetName();
    else

        [~,shortName]=fileparts(name);



        if this.isReservedReqSetName(shortName)
            error(message('Slvnv:slreq:RequirementSetNameReserved',shortName));
        end

        if~isempty(this.getReqSet(name))
            error(message('Slvnv:slreq:RequirementSetAlreadyLoaded',name));
        end

        conflictingLinkSet=this.getLinkSet(shortName);
        if~isempty(conflictingLinkSet)
            [~,conflName,conflExt]=fileparts(conflictingLinkSet.artifact);
            error(message('Slvnv:slreq:ReqsetNameConflictArtifact',shortName,[conflName,conflExt]));
        end
    end

    reqSet=this.addRequirementSet(name);
    reqSetObj=this.wrap(reqSet);
    this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSet Created',reqSetObj));
end
