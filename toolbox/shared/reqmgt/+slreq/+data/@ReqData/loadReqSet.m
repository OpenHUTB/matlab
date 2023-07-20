function reqSet=loadReqSet(this,rsname,partOptions,resolveProfile,profChecker,profNs)






    slreq.uri.errorOnReservedReqSetName(rsname);

    if nargin<3
        partOptions=[];
    end

    if nargin<4
        resolveProfile=false;
        profChecker=[];
        profNs=[];
    end


    reqSetShortName=slreq.uri.getReqSetShortName(rsname);
    reqSet=this.getReqSet(reqSetShortName);
    if~isempty(reqSet)

        validateFoundReqSet(reqSet,rsname);
        return;
    end

    reqSetFilePath=slreq.uri.getReqSetFilePath(rsname);

    if~isempty(reqSetFilePath)&&~rmiut.isCompletePath(reqSetFilePath)



        reqSetFilePath=rmiut.full_path(reqSetFilePath,pwd);
    end

    if isempty(reqSetFilePath)&&isempty(partOptions)

        rmiut.warnNoBacktrace('Slvnv:slreq:UnableToLocateReqSet',rsname);
        return;
    else

        try

            msgId='Slvnv:slreq:InvalidCorruptSLREQXFile';


            package=slreq.opc.Package(reqSetFilePath);
            try
                loadOptions=[];
                if~isempty(partOptions)
                    loadOptions=partOptions.loadOptions;
                    package.modelSid=partOptions.modelSid;
                end
                content=package.readFile([],loadOptions);
            catch ex

                error(message(msgId,reqSetFilePath));
            end


            mfReqSet=this.parseMf0File(reqSetFilePath,msgId,content,false);
        catch ex




            rethrow(ex);
        end


        if isempty(mfReqSet)||~isa(mfReqSet,'slreq.datamodel.RequirementSet')
            return;
        end




        mfReqSet.filepath=reqSetFilePath;

        mfReqSet.name=reqSetShortName;
        this.repository.requirementSets.add(mfReqSet);

        this.resolveRequirementTypesForReqSet(mfReqSet);

        reqSet=this.wrap(mfReqSet);

        this.postProcessReqSet(mfReqSet);


        if isempty(loadOptions)

            slreq.opc.unpackProxyOptions(package,mfReqSet.name);
        end

        images=slreq.opc.unpackImages(package,loadOptions);



        reqSet.collectImagesForPacking(images);



        this.refreshLinkSetsByRegistration(reqSetShortName);




        slreq.internal.callback.Utils.executeCallback(reqSet,'postLoadFcn',reqSet.postLoadFcn);


        if resolveProfile&&~isempty(profChecker)
            slreq.internal.ProfileReqType.resolveProfiles(reqSet,profChecker,profNs);
        end

        this.notify('ReqDataChange',slreq.data.ReqDataChangeEvent('ReqSet Loaded',reqSet));


        linkSetFile=slreq.uri.getLinkSetForReqSet(reqSetFilePath);
        if exist(linkSetFile,'file')==2&&...
            isempty(this.findLinkSet(linkSetFile,'linktype_rmi_slreq'))
            this.loadLinkSet(reqSetFilePath,linkSetFile);
        end

    end
end

function validateFoundReqSet(dataReqSet,reqSetFullName)
    [dirName,shortName,ext]=fileparts(reqSetFullName);
    if~isempty(dirName)
        simplGivenFullName=rmiut.simplifypath(strrep(reqSetFullName,'\','/'));
        if rmiut.cmp_paths(dataReqSet.filepath,simplGivenFullName)

            return;
        end


        error(message('Slvnv:slreq:ReqSetFileSameNameIsLoaded',[shortName,ext],reqSetFullName,dataReqSet.filepath));
    else

    end
end