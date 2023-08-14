function result=saveReqSet(this,reqSet,varargin)






    slreq.utils.assertValid(reqSet);

    if~isa(reqSet,'slreq.data.RequirementSet')
        error('Invalid argument: expected slreq.data.RequirementSet');
    end

    slreq.internal.callback.Utils.executeCallback(reqSet,'preSaveFcn',reqSet.preSaveFcn);

    modelReqSet=reqSet.getModelObj();


    assert(~isempty(modelReqSet));

    oldFilePath=modelReqSet.filepath;


    modelReqSet.MATLABVersion=version;

    slreq.data.ReqData.updateModificationInfo(modelReqSet);

    if modelReqSet.dirty

        if modelReqSet.revision>0||modelReqSet.items.Size>0
            modelReqSet.revision=modelReqSet.revision+1;
        end
    end


    saveOptions=[];
    asVersion='';
    if~isempty(varargin)
        filepath=varargin{1};
        if isempty(filepath)
            filepath=modelReqSet.filepath;
        end
        if length(varargin)>1

            asVersion=varargin{2};

            if length(varargin)>2
                saveOptions=varargin{3};
            end
        end
    else
        filepath=modelReqSet.filepath;
    end


    filepath=slreq.uri.getReqSetFilePath(filepath);

    this.setMATLABVersion(modelReqSet,asVersion);

    oldName=reqSet.name;


    if~strcmp(modelReqSet.filepath,filepath)

        reqSet.update_filepath(filepath,asVersion);
    end


    if modelReqSet.dirty
        reqSet.updateModificationInfoForDirtyItems();
    end

    if isnat(reqSet.createdOn)



        modelReqSet.createdOn=modelReqSet.modifiedOn;
    end

    if isempty(asVersion)


        reqSet.moveImagesIfNecessary(oldName)
    else

        this.migrateReqSet(modelReqSet,oldName,asVersion);
    end


    package=slreq.opc.Package(modelReqSet.filepath);
    data=this.serialize(modelReqSet,asVersion);
    if~isempty(saveOptions)
        package.modelSid=modelReqSet.modelSid;
    end
    package.save(data,saveOptions);

    slreq.opc.packImages(reqSet.getImageFilenamesToPack(),package,...
    oldName,saveOptions);






    slreq.opc.packProxyOptions(package,modelReqSet);




    slreq.opc.packAttachments(package,reqSet,modelReqSet.filepath);


    if isempty(saveOptions)

        profiles=modelReqSet.profiles;
        profileNsStr=serializeProfileNamespace(profiles);
        PROFILE_PART_NAME='/slrequirements/profileNamespace_model.xml';
        try

            slreq.opc.opc('delete',modelReqSet.filepath,'profileNamespace_model.xml');
        catch ME

        end
        slreq.opc.opc('write',modelReqSet.filepath,PROFILE_PART_NAME,false,profileNsStr);
    end

    reqSet.setDirty(false);



    myLinkSet=this.getLinkSet(reqSet.name,'linktype_rmi_slreq');



    if~isempty(myLinkSet)&&(myLinkSet.dirty||~isempty(asVersion))
        myLinkSet.save(myLinkSet.filepath,asVersion);
    end


    if reqmgt('rmiFeature','FilteredView')
        app=slreq.app.MainManager.getInstance;
        vm=app.viewManager;
        if~isempty(vm)
            vm.saveViewsForReqSet(filepath,oldFilePath);
        end
    end

    result=true;
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
