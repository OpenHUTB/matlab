function saveCoverage(fileName,varargin)





    [mcCodeCovData,hasSLCovData]=SlCov.CoverageAPI.extractMLCoderCovData(varargin{:});
    hasMLCovData=~isempty(mcCodeCovData.test)||~isempty(mcCodeCovData.data)||~isempty(mcCodeCovData.group);
    if hasSLCovData&&hasMLCovData
        error(message('Slvnv:simcoverage:BadMixedCvObjectTypes'));
    end

    invokedForSlicer=~hasMLCovData&&SlCov.CoverageAPI.isCovDataUsedBySlicer([varargin{:}]);
    if invokedForSlicer
        [status,msgId]=SlCov.CoverageAPI.checkSlicerLicense;
    else
        [status,msgId]=SlCov.CoverageAPI.checkCvLicense;
    end
    if status==0
        error(message(msgId));
    end
    fileName=convertStringsToChars(fileName);

    if~ischar(fileName)
        error(message('Slvnv:simcoverage:cvsave:DestinationFilenameNotString'));
    end
    if nargin<2
        error(message('Slvnv:simcoverage:cvsave:NotEnoughArgument'));
    end

    [path,name,ext]=cvi.ReportUtils.getFilePartsWithWriteChecks(fileName,'.cvt');
    fullFilename=fullfile(path,append(name,ext));


    if hasMLCovData
        save(fullFilename,'mcCodeCovData','-mat');
        return
    end

    cvprivate('model_name_refresh');

    firstOptionalArg=convertStringsToChars(varargin{1});

    if nargin==2&&ischar(firstOptionalArg)


        if endsWith(firstOptionalArg,[".slx",".mdl"])
            firstOptionalArg=firstOptionalArg(1:end-4);
        end

        try
            modelname=bdroot(firstOptionalArg);
            modelId=get_param(modelname,'CoverageId');
            if modelId==0
                modelId=SlCov.CoverageAPI.findModelcov(modelname);
            end
        catch MEx %#ok<NASGU>
            modelname=firstOptionalArg;
            modelId=SlCov.CoverageAPI.findModelcov(modelname);
        end

        modelId(modelId==0)=[];

        if isempty(modelId)
            error(message('Slvnv:simcoverage:cvsave:ModelNotLoaded',modelname));
        end

        saveContext=capture_model_testdata_structure(modelId);
        for ii=1:numel(modelId)
            packModelRunningTotal(modelId(ii));
        end


        savedObj=cell(0,3);
        ids=[];
        for ii=1:numel(saveContext)
            tIds=[saveContext{ii}.testLists{:}];
            ids=[ids;tIds(:)];%#ok<AGROW>
            if~isempty(saveContext{ii}.runningTotals)&&all(saveContext{ii}.runningTotals>0)
                ids=[ids;saveContext{ii}.runningTotals(:)];%#ok<AGROW>
            end
            if~isempty(saveContext{ii}.prevRunningTotals)&&all(saveContext{ii}.prevRunningTotals>0)
                ids=[ids;saveContext{ii}.prevRunningTotals(:)];%#ok<AGROW>
            end
        end

        ids=unique(ids);
        for ii=1:numel(ids)
            savedObj=[savedObj;transformCodeCovObj(ids(ii))];%#ok<AGROW>
        end


        clrObj=onCleanup(@()restoreCodeCovObj(savedObj));

        for ii=1:numel(modelId)
            SlCov.CoverageAPI.safe_set_cv_object(modelId(ii),'.topModelCov',[]);
        end
        cv('SaveModelData',modelId,fullFilename);
        restore_model_testdata_structure(saveContext);
        return

    elseif isa(varargin{1},'cv.cvdatagroup')
        cvprivate('check_cvdata_input',varargin{1});
        save_cvdatagroup(fullFilename,varargin);
    else
        tests=[];
        TestOnly=false;
        DataOnly=false;
        savedObj=cell(0,3);
        for i=1:(nargin-1)
            switch(class(varargin{i}))
            case 'cvtest'
                valid(varargin{i});
                tests=[tests,varargin{i}.id];%#ok<AGROW>
                TestOnly=true;
            case 'cvdata'

                try
                    cvprivate('check_cvdata_input',varargin{i})


                    if(varargin{i}.id==0)
                        varargin{i}=commitdd(varargin{i});
                    end
                    DataOnly=true;
                    tests=[tests,varargin{i}.id];%#ok<AGROW>

                catch Me
                    restoreCodeCovObj(savedObj);
                    rethrow(Me);
                end


                savedObj=[savedObj;transformCodeCovObj(varargin{i})];%#ok<AGROW>

            otherwise
                restoreCodeCovObj(savedObj);
                error(message('Slvnv:simcoverage:cvsave:BadInputArgument'));
            end
        end


        clrObj=onCleanup(@()restoreCodeCovObj(savedObj));

        if TestOnly&&DataOnly
            error(message('Slvnv:simcoverage:cvsave:NotBothCvtestCvdata'));
        end
        modelId=cv('get',tests(1),'.modelcov');
        check_from_same_model(modelId,tests);
        save_a_model(fullFilename,modelId,{tests},TestOnly);
    end


    function out=transformCodeCovObj(cvdOrId)

        out=[];

        try

            if isa(cvdOrId,'cvdata')
                id=cvdOrId.id;
            else
                id=cvdOrId;
            end
            obj=cv('get',id,'.data.sfcnCovData');
            if isa(obj,'SlCov.results.CodeCovDataGroup')
                b64Str=SlCov.results.CodeCovDataGroup.toBase64(obj);
                if~isempty(b64Str)

                    cv('set',id,'.data.sfcnCovData',b64Str);
                    out={cvdOrId,obj,[]};
                end
            end

            obj=cv('get',id,'.data.codeCovData');

            if isa(obj,'SlCov.results.CodeCovData')
                b64Str=SlCov.results.CodeCovData.toBase64(obj);
                if~isempty(b64Str)

                    cv('set',id,'.data.codeCovData',b64Str);
                    if isempty(out)
                        out={cvdOrId,[],obj};
                    else
                        out{3}=obj;
                    end
                end
            end

        catch

        end


        function restoreCodeCovObj(savedObj)

            for ii=1:size(savedObj,1)
                cvdOrId=savedObj{ii,1};
                sfcnobj=savedObj{ii,2};
                codeobj=savedObj{ii,3};
                if isa(cvdOrId,'cvdata')
                    id=cvdOrId.id;
                else
                    id=cvdOrId;
                end
                cv('set',id,'.data.sfcnCovData',sfcnobj);
                cv('set',id,'.data.codeCovData',codeobj);
            end


            function save_cvdatagroup(fullFilename,cvdgs)


                modelId=[];
                tests={};
                savedObj=cell(0,3);
                for cvdgIdx=1:numel(cvdgs)
                    cvdg=cvdgs{cvdgIdx};
                    if isa(cvdg,'cvdata')
                        cvdg=cv.cvdatagroup(cvdg);
                    end
                    allCVD=cvdg.getAll('Mixed');

                    for idx=1:length(allCVD)
                        ccvd=allCVD{idx};
                        try

                            if(ccvd.id==0)
                                ccvd=commitdd(ccvd);
                            end
                            save_cvdatagroup_props(cvdg,ccvd);


                            moldecvoId=cv('get',ccvd.id,'.modelcov');
                            fidx=find(modelId==moldecvoId);
                            if~isempty(fidx)
                                tests{fidx}=[tests{fidx},ccvd.id];%#ok<AGROW>
                            else
                                modelId(end+1)=cv('get',ccvd.id,'.modelcov');%#ok<AGROW>
                                tests{end+1}=ccvd.id;%#ok<AGROW>
                            end

                        catch Me
                            restoreCodeCovObj(savedObj);
                            rethrow(Me);
                        end



                        savedObj=[savedObj;transformCodeCovObj(ccvd)];%#ok<AGROW>
                    end

                    topModelCovId=cv('get',modelId(end),'.topModelcovId');
                    setMdlBlkToCopyMdlInfoInTopModel(cvdg,topModelCovId);
                end


                clrObj=onCleanup(@()restoreCodeCovObj(savedObj));

                save_a_model(fullFilename,modelId,tests,false)


                function cvdg=save_cvdatagroup_props(cvdg,cvd)
                    cv('set',cvd.id,'.cvdatagroupUniqueId',cvdg.uniqueId);
                    cv('set',cvd.id,'.cvdatagroupDescription',cvdg.description);
                    cv('set',cvd.id,'.cvdatagroupTag',cvdg.tag);
                    str=cvdg.aggregatedIds;
                    if~isempty(str)
                        if~iscell(str)
                            str={str};
                        end
                        str=strjoin(str,',');
                        cv('set',cvd.id,'.cvdatagroupAggregatedIds',str);
                    end

                    function save_a_model(fullFilename,modelId,tests,TestOnly)





                        savedContext=capture_model_testdata_structure(modelId);





                        if(~TestOnly)
                            verCleanup=onCleanup(@()restoreDbVersion(tests));
                            for idx=1:numel(tests)
                                marshalingMf0(tests{idx});
                                fixDbVersion(tests{idx});
                            end

                            if~isempty(tests)
                                cvi.RootVariant.setRootVariantFromCvdata(cvdata(tests{1}(1)));
                            end

                            allContext=sort_testdata_by_root(modelId,tests);

                            for idx=1:length(allContext)
                                context=allContext{idx};
                                roots=context.roots;
                                lists=context.lists;
                                for i=1:length(roots)
                                    if~any(cv('get',roots(i),'.runningTotal')==lists{i})
                                        cv('set',roots(i),'.runningTotal',0);
                                    end
                                    if~any(cv('get',roots(i),'.prevRunningTotal')==lists{i})
                                        cv('set',roots(i),'.prevRunningTotal',0);
                                    end
                                end
                                cv('SetTestList',context.modelcovid,[]);
                                SlCov.CoverageAPI.safe_set_cv_object(context.modelcovid,'.topModelCov',[]);
                            end

                            covIds=[];
                            for idx=1:length(allContext)
                                context=allContext{idx};
                                roots=context.roots;
                                lists=context.lists;
                                covIds=[covIds,context.modelcovid];%#ok<AGROW>
                                for i=1:length(roots)
                                    cv('SetTestList',roots(i),lists{i});
                                end


                                unsavedRoots=setdiff(cv('RootsIn',context.modelcovid),roots);
                                removeTestsFromUnsavedRoots(unsavedRoots);
                            end





                            topModelCovId=cv('get',allContext{1}.modelcovid,'.topModelcovId');
                            for idx=1:numel(allContext)
                                if~cv('get',allContext{idx}.modelcovid,'.isScript')
                                    topModelCovId=cv('get',allContext{idx}.modelcovid,'.topModelcovId');
                                    break
                                end
                            end



                            if topModelCovId>0&&~cv('ishandle',topModelCovId)
                                topModelCovId=0;
                            end



                            if topModelCovId>0
                                topModelName=cv('get',topModelCovId,'.unmangledName');
                                hasOnlyXilHarnessData=true;
                                for idx=1:numel(allContext)
                                    covId=allContext{idx}.modelcovid;
                                    isXilHarnessData=false;
                                    if SlCov.CoverageAPI.isGeneratedCode(covId)
                                        isXilHarnessData=strcmp(cv('get',covId,'.harnessModel'),topModelName)&&...
                                        (~isempty(cv('get',covId,'.ownerModel'))||...
                                        ~isempty(cv('get',covId,'.ownerBlock')));
                                    end
                                    hasOnlyXilHarnessData=hasOnlyXilHarnessData&&isXilHarnessData;
                                end
                                if hasOnlyXilHarnessData
                                    topModelCovId=0;
                                end
                            end
                            if(topModelCovId>0)&&(isempty(find(covIds==topModelCovId,1)))
                                covIds=[covIds,topModelCovId];


                                cv('set',topModelCovId,'.firstPendingTest',[]);
                                cv('SetTestList',topModelCovId,[]);
                                unsavedRoots=cv('RootsIn',topModelCovId);
                                removeTestsFromUnsavedRoots(unsavedRoots);



                                savedContext{1}.notSavedTopModel={topModelCovId,cv('get',topModelCovId,'.topModelCov')};
                                SlCov.CoverageAPI.safe_set_cv_object(topModelCovId,'.topModelCov',[]);

                            end

                            if(topModelCovId>0)

                                covIds=[topModelCovId,covIds];
                                savedContext{1}.refModelcovIds=cv('get',topModelCovId,'.refModelcovIds');
                                covIds=removeNosavedModels(topModelCovId,covIds);
                            end
                            covIds=unique(covIds,'stable');





                            updateNotSavedModels(covIds);

                            cv('SaveModelData',covIds,fullFilename);
                        else

                            for idx=1:length(modelId)
                                modelcovid=modelId(idx);
                                tests=tests{idx};
                                marshalingMf0(tests);
                                cv('set',tests,'.testobjectives',[])
                                cv('set',modelcovid,'.rootTree.child',0);
                                cv('SetTestList',modelcovid,tests);
                                SlCov.CoverageAPI.safe_set_cv_object(modelcovid,'.topModelCov',[]);
                                cv('set',modelcovid,'.blockTypes',[]);


                                topModelId=cv('get',modelcovid,'.topModelcovId');
                                if isempty(intersect(topModelId,modelId))
                                    cv('set',modelcovid,'.topModelcovId',0);
                                end

                                cv('save',fullFilename,'w',[modelcovid,tests],'CV_Database');
                            end
                        end

                        restore_model_testdata_structure(savedContext);




                        harnessModel='';
                        for modelcovId=modelId(:)'
                            if isempty(harnessModel)
                                harnessModel=cv('get',modelcovId,'.harnessModel');
                                break;
                            end
                        end
                        for modelcovId=modelId(:)'
                            if cv('get',modelcovId,'.isScript')~=1
                                modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
                                if~strcmpi(harnessModel,modelName)&&...
                                    ~cv('get',modelcovId,'.isCopyRefMdl')
                                    cvi.ReportUtils.checkModelLoaded(modelcovId);
                                    cvi.TopModelCov.checkModelConistency(modelcovId);
                                end
                            end
                        end

                        function updateNotSavedModels(covIds)


                            allModelCovIds=cv('find','all','.isa',cv('get','default','modelcov.isa'));
                            notSavedModelCovIds=setdiff(allModelCovIds,covIds);

                            for ii=1:numel(covIds)


                                refModelcovIds=cv('get',covIds(ii),'.refModelcovIds');
                                refModelcovIds(ismember(refModelcovIds,notSavedModelCovIds))=[];
                                cv('set',covIds(ii),'.refModelcovIds',refModelcovIds);


                                topModelCov=cv('get',covIds(ii),'.topModelcovId');
                                if~isempty(topModelCov)&&...
                                    (cv('ishandle',topModelCov)==0||ismember(topModelCov,notSavedModelCovIds))
                                    cv('set',covIds(ii),'.topModelcovId',0);
                                end
                            end

                            function covIds=removeNosavedModels(topModelCovId,covIds)
                                refModelcovIds=cv('get',topModelCovId,'.refModelcovIds');
                                if~isempty(refModelcovIds)
                                    newRefs=intersect(covIds,refModelcovIds);
                                    cv('set',topModelCovId,'.refModelcovIds',newRefs);
                                end


                                function check_from_same_model(modelId,tests)




                                    for i=2:length(tests)
                                        if(modelId~=cv('get',tests(i),'.modelcov'))
                                            error(message('Slvnv:simcoverage:cvsave:NotFromSameModel'));
                                        end
                                    end

                                    function packModelRunningTotal(modelcovId)
                                        roots=cv('RootsIn',modelcovId);
                                        for i=1:length(roots)
                                            runningTotalID=cv('get',roots(i),'.runningTotal');
                                            if runningTotalID>0
                                                tests=cv('TestsIn',roots(i));
                                                rmTest=0;
                                                j=1;
                                                while j<=length(tests)
                                                    if cv('get',tests(j),'.isDerived')&&(runningTotalID~=tests(j))
                                                        tests(j)=[];
                                                        rmTest=1;
                                                    end
                                                    j=j+1;
                                                end
                                                if rmTest
                                                    cv('SetTestList',roots(i),tests);
                                                end
                                            end
                                        end

                                        function allcontext=capture_model_testdata_structure(allModelcovId)
                                            allcontext={};
                                            for idx=1:length(allModelcovId)
                                                context.modelcovid=allModelcovId(idx);
                                                context.roots=cv('RootsIn',context.modelcovid);
                                                rootCount=length(context.roots);
                                                context.testLists=cell(rootCount,1);

                                                for i=1:rootCount
                                                    context.testLists{i}=cv('TestsIn',context.roots(i));
                                                    marshalingMf0(context.testLists{i});
                                                end
                                                context.pendingTests=cv('TestsIn',context.modelcovid,1);
                                                cv('SetTestList',context.modelcovid,[]);
                                                context.firstRoot=cv('get',context.modelcovid,'.rootTree.child');
                                                context.runningTotals=cv('get',context.roots,'.runningTotal');
                                                context.prevRunningTotals=cv('get',context.roots,'.prevRunningTotal');
                                                context.topModelCov=cv('get',context.modelcovid,'.topModelCov');
                                                context.topModelcovId=cv('get',context.modelcovid,'.topModelcovId');

                                                allcontext{end+1}=context;%#ok<AGROW>
                                            end

                                            function marshalingMf0(testIds)

                                                fieldNames={'logicBlkShortcircuit',...
                                                'useTimeInterval',...
'intervalStartTime'...
                                                ,'intervalStopTime',...
                                                'covBoundaryRelTol',...
                                                'covBoundaryAbsTol'};
                                                for tidx=1:numel(testIds)
                                                    testId=testIds(tidx);
                                                    settings=cv('get',testId,'.mf0.settings');
                                                    for idx=1:numel(fieldNames)
                                                        cfn=fieldNames{idx};
                                                        cv('set',testId,['.',cfn],settings.(cfn));
                                                    end
                                                end


                                                function restore_model_testdata_structure(allcontext)
                                                    for idx=1:length(allcontext)
                                                        context=allcontext{idx};
                                                        rootCount=length(context.roots);

                                                        for i=1:rootCount
                                                            cv('set',context.testLists{i},'.linkNode.parent',context.roots(i));
                                                            cv('SetTestList',context.roots(i),context.testLists{i});
                                                        end
                                                        cv('SetTestList',context.modelcovid,context.pendingTests);
                                                        cv('set',context.modelcovid,'.rootTree.child',context.firstRoot);
                                                        cv('set',context.roots,'.runningTotal',context.runningTotals);
                                                        cv('set',context.roots,'.prevRunningTotal',context.prevRunningTotals);
                                                        SlCov.CoverageAPI.safe_set_cv_object(context.modelcovid,'.topModelCov',context.topModelCov);
                                                        cv('set',context.modelcovid,'.topModelcovId',context.topModelcovId);
                                                        if isfield(context,'refModelcovIds')
                                                            cv('set',context.topModelcovId,'.refModelcovIds',context.refModelcovIds);
                                                        end
                                                        if isfield(context,'notSavedTopModel')
                                                            SlCov.CoverageAPI.safe_set_cv_object(context.notSavedTopModel{1},'.topModelCov',context.notSavedTopModel{2});
                                                        end
                                                    end


                                                    function allcontext=sort_testdata_by_root(allmodelcovid,alltests)
                                                        allcontext={};
                                                        for idx=1:length(allmodelcovid)

                                                            tests=alltests{idx};
                                                            modelcovid=allmodelcovid(idx);

                                                            roots=cv('RootsIn',allmodelcovid(idx));
                                                            lists=cell(length(roots),1);
                                                            context=[];
                                                            existingContextIdx=[];
                                                            for alci=1:numel(allcontext)
                                                                if allcontext{alci}.modelcovid==modelcovid
                                                                    context=allcontext{alci};
                                                                    existingContextIdx=alci;
                                                                    break;
                                                                end
                                                            end
                                                            if isempty(context)
                                                                context.modelcovid=modelcovid;
                                                            end

                                                            for testId=tests(:)'
                                                                parent=cv('get',testId,'.linkNode.parent');
                                                                listNum=find(roots==parent);
                                                                lists{listNum}=[lists{listNum},testId];
                                                            end
                                                            ei=[];
                                                            for i=1:numel(lists)
                                                                if isempty(lists{i})
                                                                    ei(end+1)=i;%#ok<AGROW>
                                                                end
                                                            end
                                                            lists(ei)=[];
                                                            roots(ei)=[];

                                                            if~isempty(existingContextIdx)
                                                                context.lists={[context.lists{1},lists{1}]};
                                                                allcontext{existingContextIdx}=context;%#ok<AGROW>
                                                            else
                                                                context.lists=lists;
                                                                context.roots=roots;
                                                                allcontext{end+1}=context;%#ok<AGROW>
                                                            end
                                                        end


                                                        function removeTestsFromUnsavedRoots(unsavedRoots)

                                                            for unsaveRootId=unsavedRoots(:)'
                                                                cv('SetTestList',unsaveRootId,[]);
                                                                cv('set',unsaveRootId,'.runningTotal',0);
                                                                cv('set',unsaveRootId,'.prevRunningTotal',0);
                                                            end

                                                            function setMdlBlkToCopyMdlInfoInTopModel(cvddg,topModelCovId)


                                                                if cvddg.hasMdlBlkToCopyMdlMap
                                                                    mMap=cvddg.mdlBlkToCopyMdlMap;
                                                                    serializedStr=cv.cvdatagroup.serializeMdlBlkToCopyMdlMap(mMap);
                                                                    if~isempty(serializedStr)
                                                                        cv('set',topModelCovId,'.mdlBlkToCopyMdlKeyValues',serializedStr);
                                                                    end
                                                                end


                                                                function fixDbVersion(testId)














                                                                    dbversionToRestore=cv('get',testId,'.dbVersion');
                                                                    cv('set',testId,'.dbversionToRestore',dbversionToRestore);
                                                                    cv('set',testId,'.dbVersion',SlCov.CoverageAPI.getDbVersion);



                                                                    function restoreDbVersion(tests)





                                                                        for i=1:length(tests)
                                                                            testId=tests{i};
                                                                            dbversionToRestore=cv('get',testId,'.dbversionToRestore');
                                                                            if~isempty(dbversionToRestore)
                                                                                cv('set',testId,'.dbVersion',dbversionToRestore);
                                                                            end
                                                                        end



