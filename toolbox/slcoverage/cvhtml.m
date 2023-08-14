function varargout=cvhtml(fileName,varargin)



























    try
model_name_refresh

        fileName=convertStringsToChars(fileName);

        if 1<nargin
            [varargin{:}]=convertStringsToChars(varargin{:});
        end



        if~ischar(fileName)
            error(message('Slvnv:simcoverage:cvhtml:FileNameNotString'));
        end





        if nargin<2
            if strcmp(fileName,'optionsTable')
                varargout{1}=cvi.ReportUtils.getOptionsTable;
                return;
            else
                error(message('Slvnv:simcoverage:cvhtml:AtLeast1Input'));
            end
        end

        if nargin==2&&strcmp(fileName,'help')&&ischar(varargin{1})&&...
            strcmp(varargin{1},'options')
            cvi.ReportUtils.displayOptionsHelp(fileName,varargin{:})
            return;
        end


        covMode=SlCov.CovMode.Mixed;
        covModeStrs=lower(SlCov.CovMode.getAllowedStrings(true));


        allTests={};
        cvdatagroups={};
        htmlOptions=[];
        cvhtmlSettings=[];
        isCalledFromCvHTMLDataGroup=false;
        i=1;
        while i<=length(varargin)
            arg=varargin{i};
            if isempty(arg)
                error(message('Slvnv:simcoverage:cvhtml:EmptyData'));
            end


            if isa(arg,'cv.cvdatagroup')
                classType='cv.cvdatagroup';
            else
                classType=class(arg);
            end
            switch(classType)
            case 'char'
                if strcmpi(arg,'calledFromCvHTMLDataGroup')
                    isCalledFromCvHTMLDataGroup=true;
                elseif ismember(lower(arg),covModeStrs)

                    covMode=SlCov.CovMode.fromString(arg);
                else
                    htmlOptions=arg;
                end
            case 'SlCov.CovMode'


                SlCov.CovMode.fromString(arg,1);
                covMode=arg;
            case 'cvdata'
                if length(arg)>1
                    error(message('Slvnv:simcoverage:cvhtml:NonScalarArg',i));
                end
                if~valid(arg)
                    error(message('Slvnv:simcoverage:cvdata:InvalidCvData',i));
                end
                if~validRoot(arg)
                    error(message('Slvnv:simcoverage:cvdata:InvalidCvDataRoot'));
                end
                if~isempty(allTests)
                    if allTests{1}.rootId~=arg.rootId
                        error(message('Slvnv:simcoverage:cvhtml:InvalidArgument',i));
                    end
                end
                allTests{end+1}=arg;%#ok<AGROW>
            case 'cv.coder.cvdata'
                allTests{end+1}=arg;%#ok<AGROW>
            case 'cv.cvdatagroup'
                cvdatagroups{end+1}=arg;%#ok<AGROW>
            case 'cv.coder.cvdatagroup'
                cvdatagroups{end+1}=arg;%#ok<AGROW>
            case 'cvi.CvhtmlSettings'
                cvhtmlSettings=arg;
            otherwise
                error(message('Slvnv:simcoverage:cvhtml:InvalidArgumentType',class(arg)));
            end

            i=i+1;
        end


        if isempty(allTests)&&isempty(cvdatagroups)
            error(message('Slvnv:simcoverage:cvhtml:AtLeast1Input'));
        end



        covMode=SlCov.CovMode.fixTopMode(covMode);


        if covMode~=SlCov.CovMode.Mixed
            hasThisMode=false;
            badIdx=[];
            if~isempty(cvdatagroups)
                for ii=1:numel(cvdatagroups)
                    if~isempty(cvdatagroups{ii}.getAll(covMode))
                        hasThisMode=true;
                    else
                        badIdx=[badIdx,ii];%#ok<AGROW>
                    end
                end
                cvdatagroups(badIdx)=[];
            else
                for ii=1:numel(allTests)
                    currMode=SlCov.CovMode(allTests{ii}.simMode);
                    if currMode==covMode
                        hasThisMode=true;
                    else
                        badIdx=[badIdx,ii];%#ok<AGROW>
                    end
                end
                allTests(badIdx)=[];
            end
            if~hasThisMode
                warning(message('Slvnv:simcoverage:cvhtml:NoDataForSelectedSimMode',char(covMode)));
                return
            end
        end



        allData=[allTests(:);cvdatagroups(:)];
        [mcCodeCovData,hasSLCovData]=SlCov.CoverageAPI.extractMLCoderCovData(allData{:});
        hasMLCovData=~isempty(mcCodeCovData.data)||~isempty(mcCodeCovData.group);
        if hasSLCovData&&hasMLCovData
            error(message('Slvnv:simcoverage:BadMixedCvObjectTypes'));
        end


        if hasMLCovData
            if isempty(cvhtmlSettings)
                cvhtmlSettings=cvi.CvhtmlSettings;
            end
            if~isempty(htmlOptions)
                setHtmlOptions(cvhtmlSettings,htmlOptions);
            end
            if cvhtmlSettings.generateWebViewReport&&isWebViewAvailable()
                error(message('Slvnv:simcoverage:cvhtml:WebViewExportNotSupported'));
            end
            if~isempty(mcCodeCovData.data)&&~isempty(mcCodeCovData.group)
                for ii=1:numel(mcCodeCovData.data)
                    mcCodeCovData.group{end+1}=cv.coder.cvdatagroup(mcCodeCovData.data{ii});
                end
            end
            if isempty(mcCodeCovData.group)
                if cvhtmlSettings.summaryMode==0
                    iGenMLCodeCovReport(mcCodeCovData.data,fileName,cvhtmlSettings);
                else
                    iGenMLCodeCovSummary(mcCodeCovData.data,cvhtmlSettings);
                end
            else
                cvhtml_cvdatagroup(fileName,cvdatagroups{:},cvhtmlSettings,covMode);
            end

            return
        end

        [modelcovId,modelName,cvhtmlSettings]=loadModelAndGetCvhtmlSettings(allTests,cvdatagroups,...
        cvhtmlSettings,htmlOptions,covMode);


        if~isempty(cvdatagroups)
            if isempty(cvdatagroups)
                cvdatagroups{1}=cv.cvdatagroup(allTests{1});
                for idx=2:numel(allTests)
                    cvdatagroups{end+1}=allTests{idx};%#ok<AGROW>
                end
            end
            if cvhtmlSettings.generateWebViewReport&&isWebViewAvailable()
                generateWebView(fileName,cvdatagroups{1},cvhtmlSettings);
            else
                cvhtml_cvdatagroup(fileName,cvdatagroups{:},cvhtmlSettings,covMode);
            end
            return;
        end

        if cvhtmlSettings.generateWebViewReport&&isWebViewAvailable()
            generateWebView(fileName,allTests{1},cvhtmlSettings);
        else




            [hasManySFunctions,isSimCustomCode]=iGetSFcnCovInfo(allTests);
            if~SlCov.isSLCustomCodeCovFeatureOn()
                isSimCustomCode=false;
            end
            if isSimCustomCode||isCalledFromCvHTMLDataGroup
                hasManySFunctions=false;
            end

            isCodeCov=SlCov.CovMode.isGeneratedCode(allTests{1}.simMode);

            if isCodeCov||isSimCustomCode
                if cvhtmlSettings.summaryMode==0

                    iGenCodeCovReport(allTests,fileName,modelcovId,modelName,cvhtmlSettings,isSimCustomCode);
                elseif isCodeCov
                    iGenCodeCovSummary(allTests,cvhtmlSettings);
                end
            elseif hasManySFunctions



                fakePars=cell(size(allTests));
                for ii=1:numel(allTests)
                    cvd=cv.cvdatagroup();
                    cvd.add(allTests{ii});
                    fakePars{ii}=cvd;
                end
                cvhtml_cvdatagroup(fileName,fakePars{:},cvhtmlSettings,'calledFromCvHTMLForCodeCoverage');
            else





                rpts=cvi.ReportScript(allTests,cvhtmlSettings,modelName);
                if cvhtmlSettings.summaryMode
                    generateSummary(rpts,cvhtmlSettings);
                else
                    generateDetailedReport(rpts,fileName,modelcovId,cvhtmlSettings,SlCov.CovMode.toString(allTests{1}.simMode));
                end
            end
        end
    catch Mex
        rethrow(Mex);
    end

    function[modelcovId,modelName,cvhtmlSettings]=loadModelAndGetCvhtmlSettings(allT,cvdatagroups,cvhtmlSettings,htmlOptions,covMode)
        if~isempty(cvdatagroups)
            covdata=cvdatagroups;
        else


            covdata=allT;
        end
        if iscell(covdata)
            covdata=covdata{1};
        end

        [topModelName,modelName,ownerModel,errmsg]=cvi.ReportUtils.loadTopModelAndRefModels(covdata,covMode);
        if~isempty(errmsg)
            error(errmsg);
        end

        modelcovId=[];
        try
            modelcovId=get_param(modelName,'CoverageId');
        catch MEx %#ok<NASGU>

        end

        if isempty(cvhtmlSettings)



            if isempty(topModelName)&&~isempty(ownerModel)&&isa(covdata,'cvdata')&&...
                (covdata.isSharedUtility||covdata.isCustomCode)
                try
                    if~bdIsLoaded(ownerModel)
                        load_system(ownerModel);
                        clrObj=onCleanup(@()bdlose(ownerModel));
                    end
                    topModelName=ownerModel;
                catch
                end
            end

            if~isempty(topModelName)
                cvhtmlSettings=cvi.CvhtmlSettings(topModelName,ownerModel);


                cvhtmlSettings.showReport=true;
            else
                cvhtmlSettings=cvi.CvhtmlSettings;
            end
        end
        if~isempty(htmlOptions)
            setHtmlOptions(cvhtmlSettings,htmlOptions);
        end

        if cvhtmlSettings.showReqTable&&isa(covdata,'cvdata')&&~isempty(covdata.reqTestMapInfo)


            reqInfo=covdata.reqTestMapInfo;
            if isempty(reqInfo.modelItemMap)
                modelItemMap=containers.Map();
            else
                modelItemMap=containers.Map({reqInfo.modelItemMap.Keys},{reqInfo.modelItemMap.Values});
            end
            reqInfo.modelItemMap=modelItemMap;
            cvhtmlSettings.setRequirementsMapping(reqInfo);


            cvhtmlSettings.elimFullCovDetails=false;
        end


        function isAvail=isWebViewAvailable()
            isAvail=~isempty(which('slwebview_cov'));
            if~isAvail
                warning(message('Slvnv:simcoverage:cvhtml:WebViewLicenseCheckoutFailed'));
            end


            function generateWebView(fileName,cvdata,cvhtmlSettings)


                [pkgPath,fName]=fileparts(fileName);
                pkgName=[fName,'_webview'];


                pkgFullName=fullfile(pkgPath,pkgName);
                cvi.ReportUtils.getFilePartsWithWriteChecks(pkgFullName,'');


                showReport=cvhtmlSettings.showReport&&~cvhtmlSettings.mathWorksTesting;


                sysName=cvhtmlSettings.topModelName;


                out=slwebview_cov(sysName,...
                'SearchScope','CurrentAndBelow',...
                'LookUnderMasks','all',...
                'FollowLinks','on',...
                'FollowModelReference','on',...
                'ViewFile',showReport,...
                'ShowProgressBar',true,...
                'PackageName',pkgName,...
                'PackageFolder',pkgPath,...
                'PackagingType','unzipped',...
                'CovData',cvdata);


                if~showReport
                    display(getString(message('Slvnv:simcoverage:cvhtml:exportedWebView',out)));
                end

























































                function[hasManySFunctions,isSimCustomCode]=iGetSFcnCovInfo(allTests)

                    hasManySFunctions=false;
                    hasSFunCovIds=false;
                    isSimCustomCode=false;

                    for tIdx=1:numel(allTests)


                        sfcnCovData=allTests{tIdx}.sfcnCovData;
                        if isempty(sfcnCovData)||~hasResults(sfcnCovData)
                            continue
                        end


                        allCovData=sfcnCovData.getAll();
                        modelcovId=cv('get',allTests{tIdx}.rootId,'.modelcov');
                        if cv('get',modelcovId,'.isScript')&&~isempty(allCovData)
                            isSimCustomCode=isSimCustomCode||...
                            allCovData(1).Mode==SlCov.CovMode.SLCustomCode;
                        end

                        numInstances=0;
                        for ii=1:numel(allCovData)
                            if allCovData(ii).hasResults()
                                numInstances=numInstances+numel(allCovData(ii).getNumInstances());



                                hasSFunCovIds=hasSFunCovIds||allCovData(ii).hasMetricsResults();
                            end
                        end




                        hasManySFunctions=hasManySFunctions||(numInstances>=1);
                    end

                    hasManySFunctions=hasManySFunctions&&hasSFunCovIds;


                    function iGenCodeCovSummary(allTests,cvhtmlSettings)

                        allCovData=[];
                        for ii=1:numel(allTests)
                            codeData=allTests{ii}.codeCovData;
                            codeData.setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(cvhtmlSettings,allTests{ii}));
                            allCovData=[allCovData;codeData(:)];%#ok<AGROW>
                        end
                        cellData=cell(1,numel(allCovData));
                        for ii=1:size(cellData,2)
                            cellData{ii}=allCovData(ii);
                        end

                        if isempty(allTests{end}.test)||isDerived(allTests{end})

                            metricNames={'decision','condition','mcdc','relationalop'};
                        else

                            [metricNames,toMetricNames]=getEnabledMetricNames(allTests{end});
                            if ismember('cvmetric_Structural_relationalop',toMetricNames)
                                metricNames{end+1}='relationalop';
                            end
                        end

                        if~cvhtmlSettings.filtExecMetric
                            metricNames{end+1}='statement';
                        end

                        doCovCum=numel(allTests)>1&&cvhtmlSettings.cumulativeReport;
                        args={...
                        cvhtmlSettings,...
                        'metricNames',metricNames,...
                        'cumulativeReport',doCovCum,...
                        'lastIsTotal',doCovCum...
                        };
                        args=[args,cellData];

                        cvhtmlSettings.summaryHtml=codeinstrum.internal.codecov.CodeCovData.htmlReport(cvhtmlSettings,args{:});


                        function iGenMLCodeCovSummary(allTests,cvhtmlSettings)

                            allCovData=[];
                            for ii=1:numel(allTests)
                                codeData=allTests{ii}.codeCovData;
                                allCovData=[allCovData;codeData(:)];%#ok<AGROW>
                            end
                            cellData=cell(1,numel(allCovData));
                            for ii=1:size(cellData,2)
                                cellData{ii}=allCovData(ii);
                            end


                            [metricNames,toMetricNames]=getEnabledMetricNames(allTests{end});
                            if ismember('cvmetric_Structural_relationalop',toMetricNames)
                                metricNames{end+1}='relationalop';
                            end

                            if~cvhtmlSettings.filtExecMetric
                                metricNames{end+1}='statement';
                            end

                            doCovCum=numel(allTests)>1&&cvhtmlSettings.cumulativeReport;
                            args={...
                            cvhtmlSettings,...
                            'metricNames',metricNames,...
                            'cumulativeReport',doCovCum,...
                            'lastIsTotal',doCovCum...
                            };
                            args=[args,cellData];

                            cvhtmlSettings.summaryHtml=codeinstrum.internal.codecov.CodeCovData.htmlReport(cvhtmlSettings,args{:});


                            function iGenCodeCovReport(allTests,fileName,modelcovId,modelName,cvhtmlSettings,isSimCustomCode)

                                waitbarH=[];
                                try

                                    if isempty(modelName)&&isSimCustomCode
                                        modelName=allTests{1}.modelinfo.analyzedModel;
                                    end

                                    waitbarH=cvi.ReportScript.createCovWaitBar(cvhtmlSettings,modelName);

                                    cvi.ReportUtils.prepareImageFiles(fileparts(fileName));

                                    allCovData=[];

                                    for ii=1:numel(allTests)
                                        if isSimCustomCode
                                            codeData=allTests{ii}.sfcnCovData.getAll();
                                        else
                                            codeData=allTests{ii}.codeCovData;
                                            codeData.refreshModelCovIds(allTests{ii});
                                        end
                                        codeData.setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(cvhtmlSettings,allTests{ii}));

                                        allCovData=[allCovData;codeData(:)];%#ok<AGROW>
                                    end

                                    if isempty(allTests{end}.test)||isDerived(allTests{end})

                                        metricNames={'decision','condition','mcdc','relationalop'};


                                    else

                                        [metricNames,toMetricNames]=getEnabledMetricNames(allTests{end});
                                        if ismember('cvmetric_Structural_relationalop',toMetricNames)
                                            metricNames{end+1}='relationalop';
                                        end
                                    end

                                    if~cvhtmlSettings.filtExecMetric
                                        metricNames{end+1}='statement';
                                    end

                                    [outputDir,radixName]=fileparts(fileName);
                                    if isempty(outputDir)
                                        outputDir=pwd;
                                    end

                                    doCovCum=numel(allTests)>1&&cvhtmlSettings.cumulativeReport;
                                    args={...
                                    cvhtmlSettings,...
                                    'showReport',false,...
                                    'outputDir',outputDir,...
                                    'doUniqueName',false,...
                                    'metricNames',metricNames,...
                                    'cumulativeReport',doCovCum,...
                                    'lastIsTotal',doCovCum,...
                                    'scriptsection',cvi.ReportUtils.getJScriptSection()...
                                    };

                                    if~isSimCustomCode&&~isempty(modelcovId)
                                        args=[args,{'covId',modelcovId}];
                                    end

                                    cellData=cell(1,numel(allCovData));
                                    for ii=1:size(cellData,2)
                                        cellData{ii}=allCovData(ii);
                                    end
                                    args=[args,cellData];

                                    args=[args,{...
                                    'skipFileSuffixForSingleFile',true,...
                                    'summaryfilesuffix','',...
                                    'summaryFileRadix',radixName...
                                    }];

                                    htmlFiles=codeinstrum.internal.codecov.CodeCovData.htmlReport(args{:});

                                    if~isempty(htmlFiles)
                                        baseFileName=htmlFiles{1};
                                        if cvhtmlSettings.showReport&&~cvhtmlSettings.mathWorksTesting
                                            hBrowser=local_browser_mgr('displayFile',baseFileName);
                                            if~isempty(hBrowser)
                                                cv('set',modelcovId,'modelcov.currentDisplay.browserWindow',hBrowser);
                                            else
                                                warning(message('Slvnv:simcoverage:cvhtml:UnableToOpenCoverageReport'));
                                            end
                                        end

                                        cv('set',modelcovId,'modelcov.currentDisplay.baseReportName',baseFileName);
                                    end

                                    clean_up_waitbar(waitbarH);
                                catch Mex
                                    clean_up_waitbar(waitbarH);
                                    rethrow(Mex);
                                end


                                function iGenMLCodeCovReport(allTests,fileName,cvhtmlSettings)

                                    waitbarH=[];
                                    try
                                        moduleName=allTests{1}.moduleinfo.name;
                                        waitbarH=cvi.ReportScript.createCovWaitBar(cvhtmlSettings,moduleName);

                                        cvi.ReportUtils.prepareImageFiles(fileparts(fileName));

                                        allCovData=[];

                                        for ii=1:numel(allTests)
                                            codeData=allTests{ii}.codeCovData;
                                            rptCtx=cvi.ReportUtils.getFilterCtxForReport(cvhtmlSettings,allTests{ii});
                                            rptCtx.reportViewCmd='cvhtml';
                                            rptCtx.ccvdataId=allTests{ii}.uniqueId;
                                            codeData.setFilterCtx(rptCtx);
                                            allCovData=[allCovData;codeData(:)];%#ok<AGROW>
                                        end


                                        [metricNames,toMetricNames]=getEnabledMetricNames(allTests{end});
                                        if ismember('cvmetric_Structural_relationalop',toMetricNames)
                                            metricNames{end+1}='relationalop';
                                        end

                                        if~cvhtmlSettings.filtExecMetric
                                            metricNames{end+1}='statement';
                                        end

                                        [outputDir,radixName]=fileparts(fileName);
                                        if isempty(outputDir)
                                            outputDir=pwd;
                                        end
                                        fileRadixName=radixName;
                                        if~endsWith(radixName,'_')
                                            fileRadixName(end+1)='_';
                                        end

                                        doCovCum=numel(allTests)>1&&cvhtmlSettings.cumulativeReport;
                                        args={...
                                        cvhtmlSettings.copy(cvhtmlSettings),...
                                        'showReport',false,...
                                        'outputDir',outputDir,...
                                        'doUniqueName',false,...
                                        'metricNames',metricNames,...
                                        'cumulativeReport',doCovCum,...
                                        'lastIsTotal',doCovCum,...
                                        'topMostModelName',moduleName,...
                                        'scriptsection',cvi.ReportUtils.getJScriptSection(),...
                                        'skipFileSuffixForSingleFile',true,...
                                        'summaryfilesuffix','',...
                                        'summaryFileRadix',radixName,...
                                        'radixname',fileRadixName...
                                        };

                                        for ii=1:numel(allTests)
                                            rptCtx=[];
                                            rptCtx.args=args;
                                            allTests{ii}.rptCtxInfo=rptCtx;
                                        end

                                        cellData=cell(1,numel(allCovData));
                                        for ii=1:size(cellData,2)
                                            cellData{ii}=allCovData(ii);
                                        end
                                        args=[args,cellData];

                                        htmlFiles=codeinstrum.internal.codecov.CodeCovData.htmlReport(args{:});

                                        if~isempty(htmlFiles)
                                            baseFileName=htmlFiles{1};
                                            if cvhtmlSettings.showReport&&~cvhtmlSettings.mathWorksTesting
                                                hBrowser=local_browser_mgr('displayFile',baseFileName);
                                                if isempty(hBrowser)
                                                    warning(message('Slvnv:simcoverage:cvhtml:UnableToOpenCoverageReport'));
                                                end
                                            end
                                        end

                                        clean_up_waitbar(waitbarH);
                                    catch Mex
                                        clean_up_waitbar(waitbarH);
                                        rethrow(Mex);
                                    end


                                    function clean_up_waitbar(waitbarH)
                                        if~isempty(waitbarH)
                                            delete(waitbarH);
                                        end



