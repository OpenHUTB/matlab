function group=findGroup(this,artifactUri,domain)








    group=[];



    if rmi.isInstalled()
        hostReqSet=slreq.import.docToReqSetMap(artifactUri);
        if~isempty(hostReqSet)&&exist(hostReqSet,'file')==2

            mfReqSet=this.findRequirementSet(hostReqSet);
            if isempty(mfReqSet)

                dataReqSet=this.loadReqSet(hostReqSet);
                if~isempty(dataReqSet)
                    mfReqSet=this.getModelObj(dataReqSet);
                end
            end
            if~isempty(mfReqSet)
                group=this.findGroupInReqSet(mfReqSet,artifactUri,domain);
                if~isempty(group)
                    return;
                end
            end
        end
    end


    mfReqSets=this.repository.requirementSets.toArray;
    for i=1:length(mfReqSets)
        switch mfReqSets(i).name
        case{'clipboard','default'}
            continue;
        otherwise
            group=this.findGroupInReqSet(mfReqSets(i),artifactUri,domain);
            if~isempty(group)
                return;
            end
        end
    end

end

