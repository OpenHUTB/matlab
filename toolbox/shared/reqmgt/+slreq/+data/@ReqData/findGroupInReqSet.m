function group=findGroupInReqSet(this,reqSet,artifactUri,domain)






    if isa(reqSet,'slreq.data.RequirementSet')
        reqSet=this.getModelObj(reqSet);
    end



    if slreq.utils.isLocalFile(artifactUri,domain)
        [shortFileName,aDir]=slreq.uri.getShortNameExt(artifactUri);
        group=lookForMatchingGroup(reqSet,artifactUri,domain,isempty(aDir));
        if isempty(group)&&~isempty(aDir)
            group=lookForMatchingGroup(reqSet,shortFileName,domain,true);
        end
    else

        group=lookForMatchingGroup(reqSet,artifactUri,domain,false);
    end
end

function group=lookForMatchingGroup(reqSet,wantedUri,domain,matchShortName)
    group=[];
    groups=reqSet.groups.toArray;
    for j=1:numel(groups)
        groupj=groups(j);
        if strcmp(groupj.domain,domain)
            if matchShortName
                compareWith=slreq.uri.getShortNameExt(groupj.artifactUri);
            else
                compareWith=groupj.artifactUri;
            end
            if strcmp(compareWith,wantedUri)
                group=groupj;
                return;
            end
        end
    end
end
