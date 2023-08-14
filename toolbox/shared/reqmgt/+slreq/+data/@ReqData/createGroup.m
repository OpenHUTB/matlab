function group=createGroup(this,artifactUri,domain)






    group=slreq.datamodel.Group(this.model);
    group.domain=domain;
    group.artifactUri=artifactUri;
end
