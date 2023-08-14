



function ddObj=commitdd(mObj)

    try
        if mObj.id~=0
            ddObj=mObj;
            return;
        end

        if~isa(mObj,'cvdata')
            error(message('Slvnv:simcoverage:commitdd:NonCvdataArgument'))
        end
        if~isDerived(mObj)
            error(message('Slvnv:simcoverage:commitdd:CvdataNotDerived'));
        end


        rootId=mObj.rootID;


        id=cvtest.create(0);
        cvdata=feval('cvdata',id);


        cv('set',cvdata.id,'.isDerived',1);
        cv('set',cvdata.id,'.modelcov',cv('get',rootId,'.modelcov'));


        structObj=[];
        clsInfo=properties(mObj);
        for ii=1:numel(clsInfo)
            propName=clsInfo{ii};
            try
                val=mObj.(propName);
            catch
                val=[];
            end
            if isempty(val)
                continue
            end
            structObj.(propName)=val;
        end

        structObj.localData=mObj.localData;
        fNames=fieldnames(structObj.localData.metrics);
        for i=1:length(fNames)
            mn=fNames{i};
            if strcmpi(mn,'testobjectives')
                if~isempty(structObj.localData.metrics.testobjectives)
                    cvt=cvtest(cvdata.id);
                    tofNames=fieldnames(structObj.localData.metrics.testobjectives);
                    setMetricDataOn(cvt,tofNames);
                    metricdataIds=cv('get',cvdata.id,'.testobjectives');
                    for idx=1:numel(tofNames)
                        tomn=tofNames{idx};
                        metricEnum=cvi.MetricRegistry.getEnum(tomn);
                        cv('set',metricdataIds(metricEnum),'.data.rawdata',structObj.localData.metrics.testobjectives.(tomn));
                        if isfield(structObj.localData,'trace')&&...
                            ~isempty(structObj.localData.trace)&&...
                            isfield(structObj.localData.trace,'testobjectives')&&...
                            isfield(structObj.localData.trace.testobjectives,tomn)
                            cv('set',metricdataIds(metricEnum),'.trace.rawdata',structObj.localData.trace.testobjectives.(tomn));
                        end
                    end
                else
                    cv('set',cvdata.id,'.testobjectives',[]);
                end
            else
                cv('set',cvdata.id,['.data.',mn],structObj.localData.metrics.(mn));
                if isfield(structObj.localData,'trace')&&~isempty(structObj.localData.trace)
                    if~strcmpi(mn,'sigrange')&&~strcmpi(mn,'sigsize')&&isfield(structObj.localData.trace,mn)
                        cv('set',cvdata.id,['.traceData.',mn],structObj.localData.trace.(mn));
                    end
                end
            end
        end

        cv('set',cvdata.id,'.startTime',structObj.localData.startTime);
        cv('set',cvdata.id,'.stopTime',structObj.localData.stopTime);

        cv('SetTestRootPath',cvdata.id,cv('GetRootPath',rootId));
        cv('set',cvdata.id,'.covFilter',structObj.localData.covFilter);

        cvdata.description=mObj.description;
        cvdata.tag=mObj.tag;
        cvdata.uniqueId=mObj.uniqueId;
        cvdata.aggregatedIds=mObj.aggregatedIds;

        copyModelInfo(cvdata.id,structObj.localData);
        copyTestSettings(cvdata.id,structObj.localData);

        filterData=structObj.localData.filterData;
        cv('set',cvdata.id,'.filterData',filterData);

        cvdata.setRootVariantStates(mObj.getRootVariantStates);

        value=mObj.localData.variantChecksum;
        if~isempty(value)
            chks(1)=value.u1;
            chks(2)=value.u2;
            chks(3)=value.u3;
            chks(4)=value.u4;
            cv('set',cvdata.id,'.variantChecksum',chks);
        end

        cvdata.testRunInfo=mObj.testRunInfo;

        cvdata.reqTestMapInfo=mObj.reqTestMapInfo;
        cvdata.scopeDataToReqs=mObj.scopeDataToReqs;

        cvdata.aggregatedTestInfo=mObj.aggregatedTestInfo;
        cvdata.traceOn=mObj.traceOn;
        cv('set',id,'.dbVersion',mObj.dbVersion);

        cv('set',cvdata.id,'.data.sfcnCovData',structObj.localData.sfcnCovData);
        if~isempty(structObj.localData.sfcnCovData)
            structObj.localData.sfcnCovData.setCovData(cvdata);
        end

        cv('set',cvdata.id,'.data.codeCovData',structObj.localData.codeCovData);
        if~isempty(structObj.localData.codeCovData)
            structObj.localData.codeCovData.setCovData(cvdata);
        end


        cv('RootAddTest',rootId,cvdata.id);


        ddObj=cvdata;
    catch MEx
        rethrow(MEx);
    end

    function copyModelInfo(id,localData)
        try
            fn={'modelVersion',...
            'creator',...
            'lastModifiedDate',...
            'defaultParameterBehavior',...
            'blockReductionStatus',...
            'conditionallyExecuteInputs',...
            'mcdcMode',...
            'analyzedModel',...
            'reducedBlocks',...
            'ownerModel',...
            'ownerBlock',...
            'harnessModel'};

            for idx=1:numel(fn)
                cfn=fn{idx};
                if isfield(localData.modelinfo,cfn)
                    locD=localData.modelinfo.(cfn);



                    if~strcmpi(cfn,'conditionallyExecuteInputs')||...
                        ~strcmpi(locD,'notUnique')
                        cv('set',id,['.',cfn],locD);
                        cv('set',id,['.',cfn],locD);
                    end
                end
            end
        catch MEx
            rethrow(MEx);
        end


        function copyTestSettings(id,localData)
            try
                cvt=cvtest(id);

                if~isempty(localData.testSettings)
                    cvt.settings=localData.testSettings;
                end


                fn={'logicBlkShortcircuit'};
                for idx=1:numel(fn)
                    cfn=fn{idx};
                    if isfield(localData.modelinfo,cfn)
                        locD=localData.modelinfo.(cfn);
                        oldValue=cvt.getSlcovSettings.logicBlkShortcircuit;

                        if isequal(class(oldValue),class(locD))
                            cvt.getSlcovSettings.logicBlkShortcircuit=locD;
                        end
                    end
                end

                cv('set',id,'.covSFcnEnable',localData.covSFcnEnable);

            catch MEx
                rethrow(MEx);
            end
