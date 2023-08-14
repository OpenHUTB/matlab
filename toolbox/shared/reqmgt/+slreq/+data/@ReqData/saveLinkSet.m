

function result=saveLinkSet(this,linkSet,asVersion)






    if nargin<3
        asVersion='';
    end

    modelLinkSet=linkSet.getModelObj();


    assert(~isempty(modelLinkSet));


    this.setMATLABVersion(modelLinkSet,asVersion);

    slreq.data.ReqData.updateModificationInfo(modelLinkSet);

    if~isempty(asVersion)
        this.migrateLinkSet(modelLinkSet,asVersion);
    end

    if modelLinkSet.dirty
        modelLinkSet.revision=modelLinkSet.revision+1;


        linkSet.updateModificationInfoForDirtyItems();
    end


    this.maskSelfReferences(modelLinkSet);




    if(0)
        [~,lsBase,lsExt]=fileparts(modelLinkSet.filepath);

        if contains(lsBase,'~')
            fprintf(1,'|==> Creating linkset file: %s  <==|\n\n',[lsBase,lsExt]);
        end
    end


    if~strcmp(modelLinkSet.filepath,'SCRATCH.slmx')
        package=slreq.opc.Package(modelLinkSet.filepath);
        data=this.serialize(linkSet,asVersion);
        package.save(data);


        profiles=modelLinkSet.profiles;
        if~isempty(profiles)
            profNsStr=serializeProfileNamespace(profiles);
            PROFILE_PART_NAME='/slrequirements/profileNamespace_model.xml';
            try

                slreq.opc.opc('delete',modelLinkSet.filepath,'profileNamespace_model.xml');
            catch ME

            end
            slreq.opc.opc('write',modelLinkSet.filepath,PROFILE_PART_NAME,false,profNsStr);
        end
    end


    linkSet.setDirty(false);
    result=true;

    if slreq.internal.isSharedSlreqInstalled()&&~strcmp(modelLinkSet.name,'_linkset')

        lsm=slreq.linkmgr.LinkSetManager.getInstance;
        lsm.onLinkSetSave(linkSet);
    end

end

function xmlStr=serializeProfileNamespace(profiles)

    mdl=mf.zero.Model();
    profileNamespace=systemcomposer.internal.profile.ProfileNamespace.make(mdl);
    arr=profiles.toArray();

    for idx=1:length(arr)
        profileNamespace.addProfile(arr{idx});
    end


    ser=mf.zero.io.XmlSerializer();
    xmlStr=ser.serializeToString(mdl);
end