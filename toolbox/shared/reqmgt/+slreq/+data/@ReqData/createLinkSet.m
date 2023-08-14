function linkSetObj=createLinkSet(this,artifact,domain)






    if isempty(fileparts(artifact))


        artifact=slreq.resolveArtifactPath(artifact,domain);
    end

    if~slreq.data.DataModelObj.checkLicense(artifact)
        error(message('Slvnv:slreq:SimulinkRequirementsNoLicense'));
    end

    linkSet=this.addLinkSet(artifact,domain);
    linkSetObj=this.wrap(linkSet);
    this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSet Created',linkSetObj));
    slreq.internal.Events.getInstance.notify('LinkSetCreated',slreq.internal.LinkSetEventData(linkSetObj));


end
