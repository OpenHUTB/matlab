function dataLinkSet=loadLinkSet(this,artifactName,linkSetFile,callerArtifact,forceResolveProfile)






    if nargin<4


        isCalledFromLSM=false;
        callerArtifact=artifactName;
    else
        isCalledFromLSM=true;
    end
    isCalledForOwner=~endsWith(artifactName,'.slmx');

    if nargin<5
        forceResolveProfile=false;
    end



    if~rmiut.isCompletePath(linkSetFile)
        givenPath=linkSetFile;
        linkSetFile=rmiut.full_path(linkSetFile,pwd);
        if~isfile(linkSetFile)
            shortName=slreq.uri.getShortNameExt(linkSetFile);
            throwAsCaller(MException(message('Slvnv:slreq:NeedFullPathToFile',givenPath,shortName)));
        end
    end


    mdl=mf.zero.Model();
    [prfChecker,prfNameSp]=slreq.internal.ProfileLinkType.areProfilesOutdated(linkSetFile,mdl);

    if~isempty(prfChecker)&&~forceResolveProfile
        outdatedProfile=prfChecker.isProfileOutdated();
        if outdatedProfile
            outdatedLinkSet.name=slreq.uri.getShortNameExt(linkSetFile);
            outdatedLinkSet.linkSetFile=linkSetFile;
            outdatedLinkSet.artifact=callerArtifact;
            this.notify('LinkDataChange',...
            slreq.data.LinkDataChangeEvent('LinkSet Profile Outdated',outdatedLinkSet));

            warning(message('Slvnv:slreq:LinksetProfileOutdated',outdatedLinkSet.name));
            dataLinkSet=[];
            return;
        end
    end



    sharedSlreqInstalled=slreq.internal.isSharedSlreqInstalled();









    mfLinkSet=this.findLinkSetByFilepath(linkSetFile);
    if~isempty(mfLinkSet)
        dataLinkSet=this.wrap(mfLinkSet);
    elseif isCalledForOwner
        dataLinkSet=this.getLinkSet(artifactName);
    else
        dataLinkSet=[];
    end
    if~isempty(dataLinkSet)









        if rmiut.cmp_paths(dataLinkSet.filepath,linkSetFile)

            [~,givenName,givenExt]=fileparts(artifactName);
            if~isempty(givenExt)&&~strcmp(givenExt,'.slmx')

                if~endsWith(dataLinkSet.artifact,givenExt)
                    shorterName=slreq.uri.getShortNameExt(dataLinkSet.artifact);
                    throwAsCaller(MException(message('Slvnv:slreq:ArtifactTypeMismatch',...
                    artifactName,shorterName,givenName)));
                end
                mfLinkSet=this.getModelObj(dataLinkSet);
                if slreq.data.ReqData.shouldUpdateFilePaths(mfLinkSet,artifactName,linkSetFile)
                    this.filePathUpdate(mfLinkSet,artifactName,linkSetFile);
                end
            end
            if sharedSlreqInstalled&&(isCalledForOwner||isCalledFromLSM)
                slreq.linkmgr.LinkSetManager.getInstance.addReference(dataLinkSet,callerArtifact);
            end
            return;
        else
            throwAsCaller(MException(message('Slvnv:slreq_uri:LinksForNameAlreadyLoadedFrom',artifactName,dataLinkSet.filepath)));
        end
    end


    if exist(linkSetFile,'file')==2

        try

            [content,msgId]=this.readOPCpackage(linkSetFile);


            mfLinkSet=this.parseMf0File(linkSetFile,msgId,content,false);
        catch ex



            throwAsCaller(ex);
        end


        if isempty(mfLinkSet)
            return;
        end

        if isa(mfLinkSet,'slreq.datamodel.LinkSet')







            expectedDomain=slreq.utils.getDomainLabel(artifactName);
            if~isempty(expectedDomain)
                loadedDomain=mfLinkSet.domain;
                if~contains(expectedDomain,loadedDomain)
                    mfLinkSet.delete();
                    throwAsCaller(MException(message('Slvnv:slreq:ArtifactTypeMismatch',expectedDomain,loadedDomain,artifactName)));
                end
            end

            modified=false;































































            this.filePathUpdate(mfLinkSet,artifactName,linkSetFile);



            dataLinkSet=this.getLinkSet(mfLinkSet.artifactUri);
            if~isempty(dataLinkSet)
                loadedSourcePath=mfLinkSet.artifactUri;
                loadedSlmxPath=mfLinkSet.filepath;
                mfLinkSet.delete();
                if strcmp(dataLinkSet.filepath,loadedSlmxPath)








                    if sharedSlreqInstalled&&(isCalledForOwner||isCalledFromLSM)



                        slreq.linkmgr.LinkSetManager.getInstance.addReference(dataLinkSet,callerArtifact);
                    end
                    return;
                else
                    throwAsCaller(MException(message('Slvnv:slreq_uri:LinksForNameAlreadyLoadedFrom',loadedSourcePath,dataLinkSet.filepath)));
                end
            end



            modified=modified|this.resolveLinkTypesForLinkSet(mfLinkSet);


            this.repository.linkSets.add(mfLinkSet);




            dataLinkSet=this.wrap(mfLinkSet);

            if sharedSlreqInstalled&&(isCalledForOwner||isCalledFromLSM)




                slreq.linkmgr.LinkSetManager.getInstance.addReference(dataLinkSet,callerArtifact);
            end




            this.postProcessLinkSet(mfLinkSet);

            if sharedSlreqInstalled




                if isCalledFromLSM





                    slreq.linkmgr.LinkSetUpdateMgr.getInstance.requestUpdate(dataLinkSet,true,false);
                else
                    slreq.linkmgr.LinkSetUpdateMgr.getInstance.requestUpdate(dataLinkSet,true,true);
                end
            end

            if forceResolveProfile&&~isempty(prfChecker)
                slreq.internal.ProfileLinkType.resolveProfiles(dataLinkSet,prfChecker,prfNameSp);
                modified=true;
            end



            mfLinkSet.dirty=modified;
            this.notify('LinkDataChange',slreq.data.LinkDataChangeEvent('LinkSet Loaded',dataLinkSet));
            if sharedSlreqInstalled
                slreq.internal.Events.getInstance.notify('LinkSetLoaded',slreq.internal.LinkSetEventData(dataLinkSet));
            end
        end
    end
end


