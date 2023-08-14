function instInfo=registerInstance(topModelH,id)




    narginchk(2,2);


    instInfo=[];
    coveng=cvi.TopModelCov.getInstance(topModelH);
    if~isa(coveng,'cvi.TopModelCov')||...
        coveng.topModelH~=topModelH||...
        ~cvi.TopModelCov.isTopMostModel(topModelH)
        return
    end


    origId=id;
    keys=strsplit(id,'@');
    if numel(keys)==1&&~isempty(keys{1})

        try
            if contains(id,':')


                [objH,~,~,~]=Simulink.ID.getHandle(id);
                sid=Simulink.ID.getSID(objH);
            else

                sid=Simulink.ID.getSID(id);
                origId=sid;
                [objH,~,~,~]=Simulink.ID.getHandle(sid);
            end




            if isa(objH,'Stateflow.Object')
                slBlk=Simulink.ID.getSimulinkParent(sid);
            else
                slBlk=sid;
            end
            refBlk=get_param(slBlk,'ReferenceBlock');
            if~isempty(refBlk)
                blkPath=refBlk;
            else
                blkPath=Simulink.ID.getFullName(objH);
            end
            libName=strtok(blkPath,'/');

            id=[libName,'@',sid];
        catch
            return
        end
    elseif numel(keys)==2&&~any(cellfun(@isempty,keys))

        libName=keys{1};
        sid=keys{2};
    else
        return
    end


    if~coveng.slccCov.libName2Info.isKey(libName)
        return
    end


    isFiltered=false;
    modelName=Simulink.ID.getModel(sid);
    topModelName=get_param(coveng.topModelH,'Name');
    if strcmp(modelName,topModelName)



        if cvi.SLCustomCodeCov.isMdlCovEnabled(coveng.topModelH)
            covPath=get_param(topModelName,'CovPath');
            topModelCovpath=cvi.TopModelCov.checkCovPath(topModelName,covPath);
            topModelCovpathSID=Simulink.ID.getSID(topModelCovpath);
            if~strcmp(topModelCovpathSID,sid)&&...
                ~Simulink.ID.isDescendantOf(topModelCovpathSID,sid)
                isFiltered=true;
            end
        else
            isFiltered=true;
        end
    else


        if~cvi.SLCustomCodeCov.isMdlRefCovEnabled(coveng.topModelH)||...
            ~coveng.slccCov.modelRefNameMap.isKey(modelName)
            isFiltered=true;
        end
        if coveng.slccCov.excludedModels.isKey(coveng.slccCov.modelRefNameMap(modelName))
            isFiltered=true;
        end
    end


    libInfo=coveng.slccCov.libName2Info(libName);
    instInfo=cvi.SLCustomCodeCov.newInstanceInfoStruct(id);
    instInfo.modelName=modelName;
    instInfo.libName=libName;
    instInfo.dbTrFile=libInfo.dbFile;
    instInfo.isFiltered=isFiltered;

    if isFiltered
        instInfo.dbFile='';
    else

        dbResFile=fullfile(coveng.slccCov.dbPath,[regexprep(origId,'[^a-zA-Z_0-9@]','_'),'_res.db']);
        instInfo.dbFile=SlCov.Utils.fixLongFileName(dbResFile);


        libInfo.instances=[libInfo.instances,instInfo];
        coveng.slccCov.libName2Info(libName)=libInfo;
    end
