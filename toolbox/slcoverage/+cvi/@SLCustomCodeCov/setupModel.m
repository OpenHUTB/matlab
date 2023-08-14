function setupModel(coveng,modelH)






    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end

    modelName=get_param(modelH,'Name');
    libInfo=slccprivate('getModelCustomCodeLibraries',modelName);

    for ii=1:numel(libInfo)

        libMdlName=libInfo(ii).libModelName;
        if coveng.slccCov.libName2Info.isKey(libMdlName)
            continue
        end


        libFullPath=fullfile(libInfo(ii).libPath,[libInfo(ii).libName,libInfo(ii).libExt]);
        if~SlCov.Utils.isfile(libFullPath)||~internal.slcc.cov.LibUtils.isCoverageCompatible(libFullPath)
            continue
        end

        if coveng.slccCov.libPath2Info.isKey(libFullPath)

            libPathInfo=coveng.slccCov.libPath2Info(libFullPath);
        else

            try

                coveng.slccCov.createDbFolder();


                dbFileByte=internal.slcc.cov.LibUtils.getTraceabilityDb(libFullPath);
                dbFilePath=cvi.SLCustomCodeCov.unzipDb(dbFileByte,coveng.slccCov.dbPath,libMdlName);
                libPathInfo.dbFile=SlCov.Utils.fixLongFileName(dbFilePath);



                codeTr=codeinstrum.internal.TraceabilityData(libPathInfo.dbFile);
                codeTr.close();
                codeTr.computeShortestUniquePaths();
                libPathInfo.codeTr=codeTr;


                libPathInfo.libNames=[];
                [~,libPathInfo.name]=fileparts(libPathInfo.dbFile);
                libPathInfo.libPath=libFullPath;

            catch Me %#ok<NASGU>
                continue
            end
        end


        infoStruct=cvi.SLCustomCodeCov.newInfoStruct();
        infoStruct.name=libMdlName;
        infoStruct.dbFile=libPathInfo.dbFile;
        infoStruct.libPath=libFullPath;


        coveng.slccCov.libName2Info(libMdlName)=infoStruct;
        libPathInfo.libNames=[libPathInfo.libNames,{libMdlName}];
        coveng.slccCov.libPath2Info(libFullPath)=libPathInfo;
    end
