function result=discardLinkSetChanges(this,dataLinkSet)











    result=false;


    if ischar(dataLinkSet)
        dataLinkSet=this.getLinkSet(dataLinkSet);
    end
    if~isempty(dataLinkSet)



        if~dataLinkSet.dirty
            return;
        end

        linkSetFilepath=dataLinkSet.filepath;
        if~isfile(linkSetFilepath)





            result=true;
            return;
        end


        if slreq.internal.isSharedSlreqInstalled()&&slreq.linkmgr.LinkSetManager.exists()

            lsm=slreq.linkmgr.LinkSetManager.getInstance();
            lsm.clearAllReferencesForLinkSet(dataLinkSet);
        end

        linkSetArtifact=dataLinkSet.artifact;
        this.discardLinkSet(dataLinkSet);





        newLinkSet=this.loadLinkSet(linkSetArtifact,linkSetFilepath);
        if~isempty(newLinkSet)
            result=true;
        end
    end
end
