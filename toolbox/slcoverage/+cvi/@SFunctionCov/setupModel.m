function fcnH=setupModel(coveng,modelH)










    modelH=get_param(modelH,'Handle');
    isSFcnCodeCovOn=cvi.SFunctionCov.isSFcnCodeCovOn(coveng.topModelH);

    fcnH=find_system(modelH,'FollowLinks','on','LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.activePlusStartupVariantSubsystem,...
    'BlockType','S-Function');
    isGoodBlkH=zeros(1,numel(fcnH));


    sfcnCovObj=coveng.slccCov.sfcnCov;
    sfcnName2Info=sfcnCovObj.sfcnName2Info;
    incompSFcnSet=sfcnCovObj.incompSFcnSet;

    for kk=1:numel(fcnH)

        fcnName=SlCov.Utils.fixSFunctionName(get_param(fcnH(kk),'FunctionName'));



        if strcmp(fcnName,'sf_sfun')||~isSFcnCodeCovOn
            isGoodBlkH(kk)=false;
            continue
        elseif incompSFcnSet.isKey(fcnName)
            isGoodBlkH(kk)=false;
            continue
        elseif sfcnName2Info.isKey(fcnName)
            isGoodBlkH(kk)=true;
            continue
        end


        isInHouseSFcn=isInHouseSFunction(fcnH(kk),fcnName);
        fcnSID=Simulink.ID.getSID(fcnH(kk));
        try
            isCompatible=feval(fcnName,'isCoverageCompatible');
        catch
            isCompatible=false;
        end
        if~isCompatible
            if~isInHouseSFcn



                incompSFcnSet(fcnName)={fcnSID,1};
            end
            isGoodBlkH(kk)=false;
            continue
        end


        try

            coveng.slccCov.createDbFolder();


            dbFileByte=feval(fcnName,'getCoverageTraceabilityDataBase');
            dbFilePath=cvi.SLCustomCodeCov.unzipDb(dbFileByte,coveng.slccCov.dbPath,fcnName);


            if isempty(dbFilePath)
                if~isInHouseSFcn
                    incompSFcnSet(fcnName)={fcnSID,2};
                end
                isGoodBlkH(kk)=false;
                continue
            end
        catch
            if~isInHouseSFcn
                incompSFcnSet(fcnName)={fcnSID,2};
            end
            isGoodBlkH(kk)=false;
            continue
        end


        dbFilePath=SlCov.Utils.fixLongFileName(dbFilePath);
        infoStruct=cvi.SLCustomCodeCov.newInfoStruct();
        infoStruct.name=fcnName;
        infoStruct.dbFile=dbFilePath;

        try


            codeTr=codeinstrum.internal.TraceabilityData(dbFilePath);
            codeTr.close();
            codeTr.computeShortestUniquePaths();

            infoStruct.codeTr=codeTr;

            [infoStruct.numCyclo,...
            infoStruct.numDec,...
            infoStruct.numDecOutcomes,...
            infoStruct.numCond,...
            infoStruct.truthTablesForMCDC,...
            infoStruct.exprsForMCDC,...
            infoStruct.numRelOp,...
            infoStruct.numRelOpOutcomes,...
            infoStruct.condsForMCDC]=cvi.SLCustomCodeCov.extractCovMetricInfoFromCodeTr(codeTr);
        catch

            if~isInHouseSFcn
                incompSFcnSet(fcnName)={fcnSID,3};
            end
            isGoodBlkH(kk)=false;
            continue
        end


        sfcnName2Info(fcnName)=infoStruct;
        isGoodBlkH(kk)=true;
    end


    fcnH(~isGoodBlkH)=[];
    sfcnCovObj.modelName2SFcnBlkH(get_param(modelH,'Name'))=fcnH;


    function status=isInHouseSFunction(blkH,fcnName)


        persistent mPath;
        if isempty(mPath)
            mPath=[matlabroot,filesep];
        end

        status=false;

        try
            fPath=which(fcnName);
            if isempty(fPath)
                return
            end


            if strncmp(mPath,fPath,numel(mPath))
                status=true;
                return
            end


            maskDesc=get_param(blkH,'MaskDescription');
            if strcmp(maskDesc,'Simulink:masks:GenSFuncDesc_MD')
                status=true;
                return
            end

        catch

        end

