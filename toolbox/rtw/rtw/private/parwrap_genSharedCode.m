function parwrap_genSharedCode(model,dstDir,srcDirs,genCode,...
    srcModels,isProtectedModelOrPackagedModelExtraction)
























    if~iscell(srcDirs)
        srcDirs={srcDirs};
        srcModels={srcModels};
    end







    hasFileMap=false;
    vals={};
    masterDmrFile=[dstDir,filesep,'shared_file.dmr'];
    retVal={};

    for nSrcDir=1:length(srcDirs)
        fname=fullfile(srcDirs{nSrcDir},'filemap.mat');
        fDmrFile=fullfile(srcDirs{nSrcDir},'shared_file.dmr');
        hasFileMap=(exist(fname,'file')==2);

        if(hasFileMap&&(exist(fDmrFile,'file')~=2))

            continue;
        end

        if(hasFileMap)
            srcDirFileMapMatFile=load(fname);
            vals=srcDirFileMapMatFile.fileMap.values;
        end

        objInfoArr.NumInfo=0;



        for idx=1:length(vals)
            if(strcmp(vals{idx}.kind,'type'))
                objInfoArr.objInfo{objInfoArr.NumInfo+1}=vals{idx};
                objInfoArr.NumInfo=objInfoArr.NumInfo+1;
            end
        end









        if(isProtectedModelOrPackagedModelExtraction)
            rtwprivate('rtwcgtlc','smartMergeTypesInDmrFile',...
            'smartMergeTypesInDmrFile',masterDmrFile,fDmrFile);
        end


        if(slfeature('SharedTypesInIR'))
            fileRepository=SLCG.SLCGFileRepository;
            rtwprivate('rtwcgtlc','emitSharedTypesFromDMR',...
            'parWrapGenSharedCode',masterDmrFile,fileRepository,...
            dstDir);

            try
                isERTTarget=strcmp(get_param(model,'IsERTTarget'),'on');
                if isERTTarget
                    cgtObject=get_param(model,'ERTHdrFileBannerTemplate');
                else
                    cgtObject='grt_code_template_parallel_build.cgt';
                end
                t=coder.internal.TargetObjectForParallelBuild(...
                dstDir,fileRepository,cgtObject);
                t.emitFiles;
            catch exc







                exc.message

            end

        else
            if(objInfoArr.NumInfo>0)
                add2FileMap(model,dstDir,objInfoArr,0,false);
            end
        end

        objInfoArr=[];
        objInfoArr.NumInfo=0;

        objKind=(cellfun(@(x){x.kind},vals));
        objKind=char(objKind);

        hasSharedConstant=false;
        sharedConstantsObjs={};

        for i=1:size(objKind,1)
            if strcmp(objKind(i,:),'constpdef')
                hasSharedConstant=true;
                sharedConstantsObjs=[sharedConstantsObjs,vals{i}];%#ok
            elseif strcmp(objKind(i,:),'type')
                continue;
            else
                objInfoArr.objInfo{objInfoArr.NumInfo+1}=vals{i};
                objInfoArr.NumInfo=objInfoArr.NumInfo+1;
            end

        end

        if hasSharedConstant
            retVal=addSharedConstants2FileMap(model,dstDir,...
            sharedConstantsObjs,false);

            addSharedConstants2FileMap(model,dstDir,[],true);
        end

        if(~slfeature('SharedTypesInIR'))
            add2FileMap(model,dstDir,objInfoArr,0,false);
        else
            add2FileMapSharedDataAndConstants(model,dstDir,...
            objInfoArr,0,false,masterDmrFile);
        end
    end


    if(~slfeature('SharedTypesInIR'))
        if genCode&&hasFileMap
            objInfoArr.NumInfo=0;
            objInfoArr.objInfo={};
            add2FileMap(model,dstDir,objInfoArr,1,false);
            emitSharedConstants(model,dstDir,masterDmrFile,...
            'const_params',false,false);
        end
    else
        if genCode&&~isempty(retVal)&&retVal.hasNewConstants
            objInfoArr.NumInfo=0;
            objInfoArr.objInfo={};
            add2FileMapSharedDataAndConstants(model,dstDir,...
            objInfoArr,1,false,masterDmrFile);
            emitSharedConstants(model,dstDir,masterDmrFile,...
            'const_params',false,false);
        end
    end


    for nSrcDir=1:length(srcDirs)
        mergeSharedFunctionDatabase(dstDir,srcDirs{nSrcDir},...
        srcModels{nSrcDir});
    end


    for nSrcDir=1:length(srcDirs)
        mergeSharedServerDatabase(dstDir,srcDirs{nSrcDir});
    end


    for nSrcDir=1:length(srcDirs)
        mergeSharedCoderInterface(dstDir,srcDirs{nSrcDir});
    end
end


function mergeSharedFunctionDatabase(dstDir,srcDir,childModel)


    fName='shared_file.dmr';

    sourceDbFile=fullfile(srcDir,fName);
    if(exist(sourceDbFile,'file')~=2)
        return;
    end


    masterDbFile=fullfile(dstDir,fName);
    masterDb=SharedCodeManager.SharedFunctionInterface(masterDbFile);


    srcDb=SharedCodeManager.SharedFunctionInterface(sourceDbFile);
    sharedFcnIdentities=srcDb.retrieveAllIdentities('SCM_SHARED_FUNCTIONS');
    sharedFcnData=srcDb.retrieveAllData('SCM_SHARED_FUNCTIONS');

    scmSyncSharedFunctions(masterDb,sharedFcnIdentities,...
    sharedFcnData,childModel);

end


function mergeSharedServerDatabase(dstDir,srcDir)


    fName='shared_file.dmr';

    sourceDbFile=fullfile(srcDir,fName);
    if(exist(sourceDbFile,'file')~=2)
        return;
    end


    masterDbFile=fullfile(dstDir,fName);
    masterDb=SharedCodeManager.SharedServerInterface(masterDbFile);


    srcDb=SharedCodeManager.SharedServerInterface(sourceDbFile);
    sharedFcnIdentities=srcDb.retrieveAllIdentities('SCM_SHARED_SERVERS');
    sharedFcnData=srcDb.retrieveAllData('SCM_SHARED_SERVERS');

    for i=1:length(sharedFcnIdentities)
        masterDb.registerDataUsingCaching(sharedFcnIdentities{i},...
        sharedFcnData{i});
    end
end


function mergeSharedCoderInterface(dstDir,srcDir)


    fName='shared_file.dmr';

    sourceDbFile=fullfile(srcDir,fName);
    if(exist(sourceDbFile,'file')~=2)
        return;
    end


    masterDbFile=fullfile(dstDir,fName);
    masterDb=SharedCodeManager.SharedCodeManagerInterface(masterDbFile);


    srcDb=SharedCodeManager.SharedCodeManagerInterface(sourceDbFile);
    sharedCIIds=srcDb.retrieveAllIdentities('SCM_MODEL');
    sharedCIData=srcDb.retrieveAllData('SCM_MODEL');

    for i=1:length(sharedCIIds)
        masterDb.registerDataUsingCaching(sharedCIIds{i},sharedCIData{i});
    end
end






