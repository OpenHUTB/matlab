function group=getGroup(this,artifactUri,domain,reqSet)








    if isa(reqSet,'slreq.data.RequirementSet')
        reqSet=this.getModelObj(reqSet);
    end

    group=this.findGroupInReqSet(reqSet,artifactUri,domain);

    if isempty(group)


        if slreq.utils.isLocalFile(artifactUri,domain)&&rmiut.isCompletePath(artifactUri)
            if strcmp(reqSet.name,'default')
                refPath=pwd;
            else
                refPath=reqSet.filepath;
            end
            artifactUri=slreq.uri.getPreferredPath(artifactUri,refPath);
        end
        group=this.addGroup(reqSet,artifactUri,domain);
    end
end
