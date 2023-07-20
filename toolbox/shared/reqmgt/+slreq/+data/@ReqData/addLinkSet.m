function mfLinkset=addLinkSet(this,artifact,domain)






    mfLinkset=slreq.datamodel.LinkSet(this.model);
    mfLinkset.artifactUri=artifact;
    mfLinkset.domain=domain;

    [aPath,aName,aExt]=fileparts(artifact);





    if~strcmp(domain,'linktype_rmi_simulink')||...
        strcmp(aExt,'.mdl')||...
        rmipref('StoreDataExternally')
        mfLinkset.name=aName;
        mfLinkset.filepath=rmimap.StorageMapper.getInstance.getStorageFor(artifact);


        conflictingLinkSets=this.findLinkSet(aName);
        for i=1:numel(conflictingLinkSets)
            if strcmp(mfLinkset.filepath,conflictingLinkSets(i).filepath)
                [~,~,cExt]=fileparts(conflictingLinkSets(i).artifactUri);
                [~,lfName,lfExt]=fileparts(conflictingLinkSets(i).filepath);
                rmiut.warnNoBacktrace('Slvnv:slreq:ConflictingLinkSetName',...
                [aName,aExt],[aName,cExt],[lfName,lfExt]);
            end
        end
    else




        [status,attr1]=fileattrib(artifact);
        if status&&~attr1.UserWrite



            mfLinkset.name=aName;
            mfLinkset.filepath=rmimap.StorageMapper.defaultLinkPath(aPath,aName,aExt);
        elseif isempty(aPath)&&~isfile(artifact)


            mfLinkset=configureEmbeddedLinkSet(mfLinkset,artifact);
        elseif exist(artifact,'file')==0




            mfLinkset.name=aName;
            mfLinkset.filepath=rmimap.StorageMapper.defaultLinkPath(aPath,aName,aExt);
        else

            mfLinkset=configureEmbeddedLinkSet(mfLinkset,artifact);
        end
    end

    mfLinkset.revision=0;
    this.updateModificationInfo(mfLinkset);
    mfLinkset.MATLABVersion=version;
    this.repository.linkSets.add(mfLinkset);







    mfLinkset.createdOn=mfLinkset.modifiedOn;

end

function mfLinkset=configureEmbeddedLinkSet(mfLinkset,artifact)
    [linksetPartName,linksetPart]=slreq.utils.getEmbeddedLinksetName();
    mfLinkset.name=linksetPartName;
    [~,aName]=fileparts(artifact);
    unpackedLocation=get_param(aName,'UnpackedLocation');
    mfLinkset.filepath=fullfile(unpackedLocation,linksetPart);
end
