function[tests,data]=loadCoverage(fileName,varargin)




    InvokedForSlicer=(nargin==3&&SlCov.CoverageAPI.isCovToolUsedBySlicer(varargin{2}));
    if InvokedForSlicer
        [status,msgId]=SlCov.CoverageAPI.checkSlicerLicense;
    else
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    end
    if status==0
        error(message(msgId));
    end

    fileName=convertStringsToChars(fileName);


    if~ischar(fileName)
        error(message('Slvnv:simcoverage:cvload:InvalidFirstArgument'));
    end


    [path,fileName,ext]=cvi.ReportUtils.getFilePartsWithReadChecks(fileName,'.cvt');
    fullFileName=fullfile(path,[fileName,ext]);


    tests=[];
    data=[];
    fid=fopen(fullFileName,'rt');
    headerTxt=fscanf(fid,'%s',10);
    fclose(fid);
    isMLCovData=~isempty(regexp(headerTxt,'^MATLAB.*MAT-file','once'));


    if isMLCovData
        try
            matVar=load('-mat',fullFileName);
        catch
            return
        end
        if isfield(matVar,'mcCodeCovData')&&isstruct(matVar.mcCodeCovData)&&...
            isfield(matVar.mcCodeCovData,'test')&&iscell(matVar.mcCodeCovData.test)&&...
            isfield(matVar.mcCodeCovData,'data')&&iscell(matVar.mcCodeCovData.data)&&...
            isfield(matVar.mcCodeCovData,'group')&&iscell(matVar.mcCodeCovData.group)
            [tests,data]=formCoderCvdataAndCoderCvdatagroup(matVar.mcCodeCovData);
        end
        return
    end


    cvprivate('model_name_refresh');


    restoreTotal=0;
    if~isempty(varargin)
        restoreTotal=varargin{1};
    end









    newObjects=loadCvDbNoWarn(fullFileName);

    modelVersionInData=checkVersion(newObjects,fullFileName,InvokedForSlicer);


    codeblocks=cv('get',newObjects,'codeblock.id');
    for codeobj=codeblocks(:)'
        cv('CodeBloc','refresh',codeobj);
    end


    validTests=[];
    newModels=cv('get',newObjects,'modelcov.id');
    modNames={};
    topModelId=[];
    refModels=[];

    for newModel=newModels(:)'
        modName=SlCov.CoverageAPI.getModelcovName(newModel);
        modNames{end+1}=modName;%#ok<AGROW>

        cv('FormatLink',newModel);


        origModel=findOrigModel(newModel);
        refreshModelHandles(newModel,modName,fullFileName,modelVersionInData);
        switch length(origModel)
        case 0
            validTests=[validTests,cv('TestsIn',newModel)];%#ok<AGROW>




            if~restoreTotal
                clearRunningTotal(newModel);
            end
            refModels=[refModels,newModel];%#ok<AGROW>
            if newModel==cv('get',newModel,'.topModelcovId')
                if cv('get',newModel,'.isScript')

                    cv('set',newModel,'.topModelcovId',0)
                else
                    assert(isempty(topModelId));
                    topModelId=newModel;
                end
            end
        case 1




            newTests=cv('TestsIn',newModel);

            if~restoreTotal
                clearRunningTotal(newModel);
            end


            cv('MergeModels',origModel,newModel);
            cvi.TopModelCov.moveBlockTypes(origModel,newModel);

            if newModel==cv('get',newModel,'.topModelcovId')
                if cv('get',newModel,'.isScript')

                    cv('set',newModel,'.topModelcovId',0)
                else
                    assert(isempty(topModelId));
                    topModelId=origModel;
                end
            end
            cv('delete',newModel);

            refModels=[refModels,origModel];%#ok<AGROW>
            allTests=cv('TestsIn',origModel);
            testIntersection=intersect(newTests,allTests);
            for idx=1:numel(testIntersection)
                cv('set',testIntersection(idx),'.modelcov',origModel);
            end

            validTests=[validTests,testIntersection];%#ok<AGROW>



            refreshModelHandles(origModel,modName,fullFileName,modelVersionInData);
        otherwise
            error(message('Slvnv:simcoverage:cvload:ConsistencyProblem'));
        end

    end
    if isempty(topModelId)


        for ii=1:numel(refModels)

            if~cv('get',refModels(ii),'.isScript')
                topModelId=refModels(ii);
                break
            end
        end

        if isempty(topModelId)
            topModelId=refModels(1);
        end
    end
    setMdlRefAssoc(topModelId,refModels);







    if isempty(validTests)
        tests=[];
        data=[];
        return;
    end
    tests=cell(1,length(validTests));
    data=cell(1,length(validTests));
    hasResults=cv('HasResults',validTests);

    for i=1:length(validTests)
        [verSavedIn,verRecordedIn]=getDataVersion(validTests(i));
        tests{i}=cvtest(validTests(i));

        if hasResults(i)||~isempty(cv('get',validTests(i),'.stopTime'))
            data{i}=cvdata(validTests(i));

            if cv('get',validTests(i),'.isDerived')
                tests{i}={};
            end

            invokeFromBase64Old=isReleaseBefore20a(verSavedIn);


            b64Str=data{i}.sfcnCovData;
            if ischar(b64Str)&&~isempty(b64Str)
                if invokeFromBase64Old
                    data{i}.sfcnCovData=SlCov.results.CodeCovDataGroup.fromBase64Old(b64Str);
                else
                    data{i}.sfcnCovData=SlCov.results.CodeCovDataGroup.fromBase64(b64Str);
                end
                fixCodeCovDbVersion(data{i}.sfcnCovData,verRecordedIn);
            end
            b64Str=data{i}.codeCovData;
            if ischar(b64Str)&&~isempty(b64Str)
                data{i}.codeCovData=SlCov.results.CodeCovData.fromBase64(b64Str);
                fixCodeCovDbVersion(data{i}.codeCovData,verRecordedIn);



                refreshSimMode(data{i});
            end
        end

        if~strcmp(verRecordedIn,verSavedIn)

            cv('set',validTests(i),'.dbVersion',verRecordedIn);
        end
    end
    [data,tests]=form_cvdatagroup(modNames,data,tests);
    if~InvokedForSlicer
        setCvreportData(data);
    end


    function refreshModelHandles(modelcovId,modelName,fullFileName,modelVersionInData)
        try
            slHandle=get_param(modelName,'Handle');
        catch Mex %#ok<NASGU>
            slHandle=0;
        end

        if slHandle

            cv('set',modelcovId,'modelcov.handle',slHandle);
            [status,msg]=cvi.TopModelCov.updateModelHandles(modelcovId,modelName);
            if status==0
                [newVersion,oldVersion]=SlCov.CoverageAPI.getModelVersions(modelcovId,modelVersionInData);
                backtraceState=warning('off','backtrace');
                restoreBacktrace=onCleanup(@()warning(backtraceState));
                warning(message('Slvnv:simcoverage:cvload:DataConsistencyProblem',modelName,newVersion,fullFileName,oldVersion,msg{1}));
            end

            cvi.TopModelCov.checkModelConistency(modelcovId);
        end


        function fixCodeCovDbVersion(codeCovData,dbVersion)

            if isempty(codeCovData)
                return
            end
            if isa(codeCovData,'SlCov.results.CodeCovData')
                codeCovData.CvDbVersion=dbVersion;
            else
                cvds=codeCovData.getAll();
                for ii=1:numel(cvds)
                    cvds(ii).CvDbVersion=dbVersion;
                end
            end


            function origModel=findOrigModel(newModelId)
                modName=SlCov.CoverageAPI.getModelcovMangledName(newModelId);
                matchingModelsIds=SlCov.CoverageAPI.findModelcovMangled(modName);
                matchingModelsIds=matchingModelsIds(matchingModelsIds~=newModelId);
                origModel=[];



                if~isempty(matchingModelsIds)
                    if SlCov.CoverageAPI.isGeneratedCode(newModelId)
                        matchingModelsIds=filterXILCustomCodeModelcovIds(newModelId,matchingModelsIds);
                    elseif strcmpi(cv('Feature','ModelCov Compatibility'),'on')
                        foundIt=false;
                        for idx=1:numel(matchingModelsIds)
                            if SlCov.CoverageAPI.isCompatible(newModelId,matchingModelsIds(idx))

                                matchingModelsIds=matchingModelsIds(idx);
                                foundIt=true;
                                break;
                            end
                        end
                        if~foundIt
                            return;
                        end

                    end
                end




                if all(arrayfun(@(x)SlCov.CoverageAPI.isGeneratedCode(x),matchingModelsIds))
                    newOwnerBlock=cv('get',newModelId,'.ownerBlock');
                    for idx=1:numel(matchingModelsIds)
                        cmId=matchingModelsIds(idx);
                        cob=cv('get',cmId,'.ownerBlock');
                        if strcmpi(newOwnerBlock,cob)
                            origModel=[origModel,cmId];%#ok<AGROW>
                        end
                    end
                else
                    origModel=matchingModelsIds;
                end


                function testIds=findTestIdsForModelcovId(modelCovId)
                    testIds=[];


                    allTests=cv('find','all','.isa',cv('get','default','testdata.isa'));
                    if isempty(allTests)
                        return
                    end


                    testIds=allTests(cv('get',allTests,'.modelcov')==modelCovId);


                    function matchingModelsIds=filterXILCustomCodeModelcovIds(newModelId,matchingModelsIds)


                        testIds=findTestIdsForModelcovId(newModelId);
                        if isempty(testIds)
                            return
                        end
                        testId=testIds(1);




                        if~(cv('HasResults',testId)||~isempty(cv('get',testId,'.stopTime')))
                            return
                        end

                        cvd=cvdata(testId);
                        if~cvd.isCustomCode
                            return
                        end

                        b64Str=cvd.codeCovData;
                        if~ischar(b64Str)||isempty(b64Str)
                            return
                        end

                        [~,verRecordedIn]=getDataVersion(testId);
                        cvd.codeCovData=SlCov.results.CodeCovData.fromBase64(b64Str);
                        fixCodeCovDbVersion(cvd.codeCovData,verRecordedIn);

                        files=cvd.codeCovData.CodeTr.getFilesInResults();
                        if isempty(files)
                            return
                        end
                        files([files.kind]~=internal.cxxfe.instrum.FileKind.SOURCE)=[];
                        if isempty(files)
                            return
                        end
                        fullPath=files(end).path;


                        badIdx=false(size(matchingModelsIds));
                        for ii=1:numel(matchingModelsIds)

                            if~SlCov.CoverageAPI.isGeneratedCode(matchingModelsIds(ii))
                                continue
                            end

                            ct=cv('get',matchingModelsIds(ii),'.currentTest');
                            if ct==0

                                testIds=findTestIdsForModelcovId(matchingModelsIds(ii));
                                if isempty(testIds)
                                    continue
                                end
                                ct=testIds(1);
                            end
                            if ct==0
                                continue
                            end

                            cvdCurr=cvdata(ct);
                            if~cvd.isCustomCode
                                continue
                            end

                            files=cvdCurr.codeCovData.CodeTr.getFilesInResults();
                            if~isempty(files)&&~ismember(fullPath,{files.path})
                                badIdx(ii)=true;
                            end
                        end
                        matchingModelsIds(badIdx)=[];


                        function setCvreportData(data)
                            for idxd=1:numel(data)
                                cdata=data{idxd};
                                if isa(cdata,'cv.cvdatagroup')
                                    allNames=cdata.allNames();
                                    for idxn=1:numel(allNames)
                                        cvd=cdata.get(allNames{idxn});
                                        if~isempty(cvd)&&valid(cvd(1))
                                            cvreportdata(allNames{idxn},cvd(1))
                                        end
                                    end
                                elseif valid(cdata)
                                    cvreportdata(cdata.modelinfo.analyzedModel,cdata);
                                end
                            end


                            function setMdlRefAssoc(topModelId,refModels)

                                cv('set',topModelId,'.refModelcovIds',refModels);
                                for idx=1:numel(refModels)
                                    cv('set',refModels(idx),'.topModelcovId',topModelId);
                                end


                                function cvdg=set_cvdatagroup_props(cvdg,cvd)
                                    cvdg.uniqueId=cv('get',cvd.id,'.cvdatagroupUniqueId');
                                    cvdg.description=cv('get',cvd.id,'.cvdatagroupDescription');
                                    cvdg.tag=cv('get',cvd.id,'.cvdatagroupTag');
                                    str=cv('get',cvd.id,'.cvdatagroupAggregatedIds');
                                    if~isempty(str)
                                        cvdg.aggregatedIds=strsplit(str,',');
                                    end


                                    function[data,tests]=form_cvdatagroup(modNames,data,tests)

                                        if length(modNames)==1
                                            return;
                                        end
                                        uniqueIdMap=containers.Map('KeyType','char','ValueType','any');
                                        cvdgs=[];
                                        cvtgs=[];
                                        cvdgIdx=0;
                                        for idx=1:length(data)
                                            if isempty(data{idx})
                                                data(idx)=[];
                                                tests(idx)=[];
                                            elseif isempty(cv('get',data{idx}.id,'.cvdatagroupUniqueId'))

                                                return;
                                            else
                                                ccvd=data{idx};
                                                ccvt=tests{idx};
                                                cvdgUid=cv('get',ccvd.id,'.cvdatagroupUniqueId');
                                                if uniqueIdMap.isKey(cvdgUid)
                                                    cvdgIdx=uniqueIdMap(cvdgUid);
                                                else
                                                    cvdgIdx=cvdgIdx+1;
                                                    uniqueIdMap(cvdgUid)=cvdgIdx;
                                                end

                                                if cvdgIdx~=0
                                                    if isempty(cvdgs)||(numel(cvdgs)<cvdgIdx)||isempty(cvdgs{cvdgIdx})
                                                        cvdgs{cvdgIdx}=cv.cvdatagroup(ccvd);%#ok<AGROW>
                                                        cvdgs{cvdgIdx}=set_cvdatagroup_props(cvdgs{cvdgIdx},ccvd);%#ok<AGROW>
                                                    else
                                                        cvdgs{cvdgIdx}.add(ccvd);
                                                    end
                                                    if~isempty(ccvt)
                                                        if isempty(cvtgs)||(numel(cvtgs)<cvdgIdx)||isempty(cvtgs{cvdgIdx})
                                                            cvtgs{cvdgIdx}=cv.cvtestgroup(ccvt);%#ok<AGROW>
                                                            cvdgs{cvdgIdx}=set_cvdatagroup_props(cvdgs{cvdgIdx},ccvd);%#ok<AGROW>
                                                        else
                                                            cvtgs{cvdgIdx}.add(ccvt);
                                                        end
                                                    end
                                                end
                                            end
                                        end

                                        ei=[];
                                        for i=1:numel(cvdgs)
                                            if isempty(cvdgs{i})
                                                ei(end+1)=i;%#ok<AGROW>
                                            end
                                        end
                                        cvdgs(ei)=[];
                                        if~isempty(cvtgs)
                                            cvtgs(ei)=[];
                                        end

                                        data=cvdgs;
                                        tests=cvtgs;




                                        function clearRunningTotal(model)


                                            roots=cv('RootsIn',model);
                                            for i=1:length(roots)
                                                cv('set',roots(i),'.runningTotal',0);
                                            end


                                            function newObjects=loadCvDbNoWarn(fullFileName)
                                                warning_state=warning('off');
                                                warningCleanup=onCleanup(@()warning(warning_state));
                                                newObjects=cv('load',fullFileName,'CV_Database');


                                                function res=isReleaseBefore20a(dbVersion)
                                                    res=contains(dbVersion,'2020a')||str2double(dbVersion(3:end-2))<2020;

                                                    function modelVersionInData=checkVersion(newObjects,fullFileName,InvokedForSlicer)
                                                        testIds=cv('find',newObjects,'.isa',cv('get','default','testdata.isa'));
                                                        currentDbVersion=SlCov.CoverageAPI.getDbVersion;
                                                        modelVersionInData='';
                                                        for idx=1:numel(testIds)
                                                            dbVersion=cv('get',testIds(idx),'.dbVersion');
                                                            modelVersionInData=cv('get',testIds(idx),'.modelVersion');
                                                            marshalingMf0(testIds(idx));
                                                            if~strcmpi(currentDbVersion,dbVersion)



                                                                ver_err_msg=[];
                                                                if InvokedForSlicer||isempty(dbVersion)

                                                                    ver_err_msg=getString(message('Slvnv:simcoverage:cvload:VerErrMsg_NoVerInfo'));
                                                                elseif string(dbVersion)>string(currentDbVersion)

                                                                    ver_err_msg=getString(message('Slvnv:simcoverage:cvload:VerErrMsg',dbVersion));
                                                                else

                                                                    fixVersions(testIds(idx),newObjects);
                                                                end
                                                                if~isempty(ver_err_msg)

                                                                    cv('delete',newObjects);
                                                                    error(message('Slvnv:simcoverage:cvload:IncompatibleVersion',fullFileName,ver_err_msg,currentDbVersion));
                                                                end
                                                            end
                                                        end

                                                        function fixVersions(testId,newObjects)

                                                            modelcovIds=cv('find',newObjects,'.isa',cv('get','default','modelcov.isa'));
                                                            cvdataVer=cv('get',testId,'.dbVersion');
                                                            if isempty(cvdataVer)
                                                                cvdataVer='(R2017a)';
                                                            end
                                                            for idx=1:numel(modelcovIds)
                                                                cmc=modelcovIds(idx);
                                                                modelcovVer=cv('get',cmc,'.dbVersion');
                                                                if~strcmpi(cvdataVer,modelcovVer)
                                                                    cv('set',cmc,'.dbVersion',cvdataVer);

                                                                    modelName=cv('get',cmc,'.unmangledName');
                                                                    if isempty(modelName)
                                                                        modelName=cv('get',cmc,'.name');
                                                                    end
                                                                    SlCov.CoverageAPI.setModelcovName(cmc,modelName);
                                                                end
                                                            end

                                                            cv('set',testId,'.dbVersion',cvdataVer);

                                                            SlCov.CoverageAPI.fixReleaseDatabaseCompatibility(testId,cvdataVer,newObjects);
                                                            for idx=1:numel(modelcovIds)
                                                                SlCov.CoverageAPI.fixReleaseChecksumCompatibility(modelcovIds(idx));
                                                            end

                                                            function marshalingMf0(testId)
                                                                settings=cv('get',testId,'.mf0.settings');
                                                                if isempty(settings)
                                                                    cvtest.setMf0(testId);
                                                                    settings=cv('get',testId,'.mf0.settings');
                                                                end

                                                                fieldNames={'logicBlkShortcircuit',...
                                                                'useTimeInterval',...
'intervalStartTime'...
                                                                ,'intervalStopTime',...
                                                                'covBoundaryRelTol',...
                                                                'covBoundaryAbsTol'};

                                                                for idx=1:numel(fieldNames)
                                                                    cfn=fieldNames{idx};
                                                                    settings.(cfn)=cv('get',testId,['.',cfn]);
                                                                end


                                                                function[verSavedIn,verRecordedIn]=getDataVersion(testId)

















                                                                    verSavedIn=cv('get',testId,'.dbVersion');
                                                                    dbVersionToRestore=cv('get',testId,'.dbversionToRestore');
                                                                    if isempty(dbVersionToRestore)
                                                                        verRecordedIn=verSavedIn;
                                                                    else
                                                                        verRecordedIn=dbVersionToRestore;
                                                                    end


                                                                    function[tests,data]=formCoderCvdataAndCoderCvdatagroup(mcCodeCovData)


                                                                        numData=numel(mcCodeCovData.data);
                                                                        numGroup=numel(mcCodeCovData.group);
                                                                        numEntries=numData+numGroup;
                                                                        tests=cell(1,numEntries);
                                                                        data=cell(1,numEntries);

                                                                        for ii=1:numData
                                                                            if isa(mcCodeCovData.data{ii},'cv.coder.cvdata')
                                                                                data{ii}=mcCodeCovData.data{ii};
                                                                                tests{ii}=data{ii}.test;
                                                                            end
                                                                        end

                                                                        for ii=1:numGroup
                                                                            if isa(mcCodeCovData.group{ii},'cv.coder.cvdatagroup')
                                                                                data{ii+numData}=mcCodeCovData.group{ii};
                                                                                allData=mcCodeCovData.group{ii}.getAll();
                                                                                allTests={};
                                                                                for jj=1:numel(allData)
                                                                                    allTests=[allTests,allData{jj}(1).test];%#ok<AGROW>
                                                                                end
                                                                                tests{ii+numData}=allTests;
                                                                            end
                                                                        end

                                                                        badDataIdx=cellfun(@isempty,data);
                                                                        tests(badDataIdx)=[];
                                                                        data(badDataIdx)=[];


                                                                        if numel(data)>0
                                                                            return
                                                                        end
                                                                        numTests=numel(mcCodeCovData.test);
                                                                        tests=cell(1,numTests);
                                                                        for ii=1:numTests
                                                                            if isa(mcCodeCovData.test{ii},'cv.coder.cvtest')
                                                                                tests{ii}=mcCodeCovData.test{ii};
                                                                            end
                                                                        end
                                                                        tests(cellfun(@isempty,tests))=[];
                                                                        data=cell(1,numel(tests));



