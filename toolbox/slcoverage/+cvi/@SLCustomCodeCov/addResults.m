function addResults(coveng,modelCovId)







    if nargin==2&&~isempty(modelCovId)

        if cv('get',modelCovId,'.simMode')==SlCov.CovMode.Normal
            cvi.SFunctionCov.addResults(coveng,modelCovId);
        end
        return
    end


    if~SlCov.isSLCustomCodeCovFeatureOn()
        return
    end



    cvt=cvi.SLCustomCodeCov.getCvTest(coveng);
    if isempty(cvt)
        return
    end

    settings=cvt.settings;
    hasDec=settings.decision;
    hasCond=settings.condition;
    hasMcdc=settings.mcdc;
    hasRelationalBoundary=settings.relationalop;
    mcdcMode=SlCov.getMcdcMode(coveng.topModelH);

    metricNames={'Decision','Condition','MCDC','RelationalBoundary','Statement','FunEntry','FunExit','FunCall'};
    idx=true(size(metricNames));
    idx(1)=hasDec;
    idx(2)=hasCond;
    idx(3)=hasMcdc;
    idx(4)=hasRelationalBoundary;
    metricNames(~idx)=[];


    libName2Info=coveng.slccCov.libName2Info;
    libPath2Info=coveng.slccCov.libPath2Info;

    libPaths=libPath2Info.keys();
    for ii=1:numel(libPaths)

        libPathInfo=libPath2Info(libPaths{ii});



        if isempty(libPathInfo.dbFile)
            continue
        end


        allInstances=[];
        for jj=1:numel(libPathInfo.libNames)
            if libName2Info.isKey(libPathInfo.libNames{jj})
                libInfo=libName2Info(libPathInfo.libNames{jj});
                allInstances=[allInstances;libInfo.instances(:)];%#ok<AGROW>
            end
        end


        if isempty(allInstances)
            continue
        end



        [~,idxInst]=unique({allInstances.name},'last');
        allInstances=allInstances(idxInst);


        for jj=1:numel(allInstances)
            keys=strsplit(allInstances(jj).name,'@');
            codeCovDataArgs={...
            'instances',struct(...
            'name',allInstances(jj).libName,...
            'SID',keys{2},...
            'resHitsFile',allInstances(jj).dbFile...
            ),...
            'metricNames',metricNames,...
            'mcdcMode',mcdcMode...
            };

            locAddResults(coveng,allInstances(jj).dbTrFile,codeCovDataArgs,libPathInfo);
        end
    end


    function locAddResults(coveng,traceabilityDbFilePath,codeCovDataArgs,libPathInfo)

        fName2Info=coveng.slccCov.fileName2Info;

        files=libPathInfo.codeTr.getFilesInResults();
        for ii=1:numel(files)
            file=files(ii);
            if file.kind~=internal.cxxfe.instrum.FileKind.SOURCE
                continue
            end



            fName=file.shortPath;
            [~,fName1,fExt]=fileparts(fName);
            fName=[fName1,fExt];
            if~fName2Info.isKey(fName)
                continue
            end
            fChk2Info=fName2Info(fName);


            fChk=sprintf('%02X',file.structuralChecksum.toArray());
            if~fChk2Info.isKey(fChk)
                continue
            end
            fileInfo=fChk2Info(fChk);


            fIdx=find(strcmp(libPathInfo.name,fileInfo.libName));
            if isempty(fIdx)
                continue
            end


            fileCovId=fileInfo.covId;
            testId=cv('get',fileCovId,'.currentTest');
            if testId~=0
                coveng.initHarnessInfo(fileCovId);
                ccCodeCovData=cv('get',testId,'.data.sfcnCovData');
                if~isa(ccCodeCovData,'SlCov.results.CodeCovDataGroup')||isempty(ccCodeCovData)
                    ccCodeCovData=SlCov.results.CodeCovDataGroup();
                end


                filePath=files(fileInfo.fileIdx(fIdx)).path;
                scriptName=SlCov.CoverageAPI.getModelcovName(fileCovId);
                traceabilityData=codeinstrum.internal.TraceabilityData(traceabilityDbFilePath,libPathInfo.name);
                traceabilityData.setSharedFilesAsCurrentModule({filePath},scriptName);
                traceabilityData.close();
                subObj=SlCov.results.CodeCovData(...
                'traceabilityData',traceabilityData,...
                codeCovDataArgs{:},'name',scriptName);
                subObj.Mode=SlCov.CovMode.SLCustomCode;


                cvd=ccCodeCovData.get(scriptName);
                if isempty(cvd)
                    cvd=subObj;
                else

                    cvd=cvd+subObj;
                end
                ccCodeCovData.add(cvd);
                covdata=cvdata(testId);
                covdata.sfcnCovData=ccCodeCovData;
            end

        end


