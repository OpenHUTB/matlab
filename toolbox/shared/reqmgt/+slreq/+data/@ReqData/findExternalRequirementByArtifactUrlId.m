



function dataReqs=findExternalRequirementByArtifactUrlId(this,dataReqSet,artifactDomain,artifactUri,artifactId)









    dataReqs=slreq.data.Requirement.empty;


    isShortName=isempty(fileparts(artifactUri));
    if~isShortName
        artifactUri=strrep(artifactUri,'\','/');
    end

    mfReqs=slreq.datamodel.ExternalRequirement.empty();

    mfReqset=dataReqSet.getModelObj();
    groups=mfReqset.groups.toArray();
    for i=1:numel(groups)
        group=groups(i);


        if~isempty(artifactDomain)&&~strcmp(group.domain,artifactDomain)
            continue;
        end

        compareWith=strrep(group.artifactUri,'\','/');
        if isShortName
            compareWith=slreq.uri.getShortNameExt(compareWith);
        end

        if strcmp(compareWith,artifactUri)


            mfReqs=group.items{artifactId};
            break;
        end
    end


    for i=1:length(mfReqs)
        dataReqs(i)=this.wrap(mfReqs(i));
    end
end
