function varargout=cvmodelview(covdata,varargin)











    SlCov.CoverageAPI.checkCvdataInput(covdata);

    try

        cvhtmlSettings=[];
        covMode=[];
        covModeStrs=lower(SlCov.CovMode.getAllowedStrings(true));
        optsSeen=false;
        modeSeen=false;
        for ii=1:numel(varargin)
            arg=varargin{ii};
            if~modeSeen&&(isa(arg,'SlCov.CovMode')||((ischar(arg)||isStringScalar(arg))&&ismember(lower(arg),covModeStrs)))
                covMode=SlCov.CovMode.fromString(arg);
                modeSeen=true;
            elseif~optsSeen&&isa(arg,'cvi.CvhtmlSettings')
                cvhtmlSettings=arg;
                optsSeen=true;
            end
        end




        [topModelName,~,ownerModel,errmsg]=cvi.ReportUtils.loadTopModelAndRefModels(covdata,covMode);
        if~isempty(errmsg)
            error(errmsg);
        end
        if isempty(topModelName)
            return;
        end

        topModelcovId=get_param(topModelName,'CoverageId');

        if isempty(cvhtmlSettings)

            options=cvi.CvhtmlSettings(topModelName,ownerModel);
            options.modelDisplay=1;
        else
            options=cvhtmlSettings;
        end
        if options.modelDisplay
            topModelH=get_param(topModelName,'handle');
            slprivate('remove_hilite',topModelH)
        end
        if options.mathWorksTesting
            return;
        end
        hasInfoToDisplay=false;
        infObj=cvi.Informer.createInstance(topModelcovId,options);

        infObj.createDetailedReport(covdata);
        if isa(covdata,'cv.cvdatagroup')
            allD=covdata.getAll(covMode);
            highlightedModelList=cell(size(allD));
            for idx=1:length(allD)
                cvd=allD{idx};
                highlightedModelList{idx}=display_on_model(cvd,infObj,options);
            end
            hasInfoToDisplay=~isempty(allD);
        else
            highlightedModelList{1}=[];
            if isempty(covMode)||covMode==SlCov.CovMode.Mixed||covdata.simMode==covMode
                highlightedModelList{1}=display_on_model(covdata,infObj,options);
                hasInfoToDisplay=true;
            end
        end

        if options.modelDisplay
            infObj.activateMap();
        end

        if hasInfoToDisplay



            SlCov.CoverageAPI.setActiveData(topModelName,covdata);
            cvi.Informer.markHighlightingApplied(topModelName,true);


            highlightedModelList{end+1}=topModelName;
            studios=cvi.Informer.getStudiosForModels(highlightedModelList);
            for i=1:length(studios)
                SlCov.Toolstrip.openCoverageApp(studios(i));
                cvi.Informer.openCoverageDetails(studios(i))
            end
        elseif~isempty(covMode)
            warning(message('Slvnv:simcoverage:cvmodelview:NoDataForSelectedSimMode',char(covMode)));
        end

        if nargout>1&&options.generatWebViewReportData
            varargout{1}=createWebViewStorage(infObj);
            if nargout==2
                varargout{2}=infObj;
            end
        end
    catch MEx
        rethrow(MEx);
    end



    function highlightedModel=display_on_model(covdata,infObj,options)
        highlightedModel=[];
        hasCodeCov=any(SlCov.CovMode.isGeneratedCode([covdata.simMode]));
        allCovData=covdata;
        if hasCodeCov
            covdata=covdata(1);
        end

        modelCovId=cvi.ReportUtils.getModelCovId(covdata);
        if isempty(modelCovId)
            return
        end

        hasFilter=~isempty(covdata.filter);
        [metricNames,toMetricNames]=cvi.ReportUtils.get_common_metric_names(covdata);
        if isempty(metricNames)&&isempty(toMetricNames)&&~hasFilter&&~hasCodeCov
            return;
        end

        tmpMetricNames=setdiff(metricNames,{'sigrange','sigsize'});
        cvstruct=report_create_structured_data({covdata},covdata.id,tmpMetricNames,toMetricNames,options);
        if isempty(cvstruct.system)&&~hasFilter&&~hasCodeCov
            return;
        end
        if hasCodeCov
            cvstruct.codeCovRes=containers.Map('KeyType','char','ValueType','any');
            for ii=1:numel(allCovData)
                cvd=allCovData(ii);
                resObj=cvd.codeCovData;
                if~isempty(resObj)
                    resObj.refreshModelCovIds(cvd);
                    cvstruct.codeCovRes(char(cvd.simMode))=resObj;
                    modelName=resObj.Name;
                end
            end
            modelcovId=cv('get',covdata.rootId,'.modelcov');
            infObj.addModel(modelcovId);
        else
            modelcovId=cv('get',covdata.rootId,'.modelcov');
            modelName=SlCov.CoverageAPI.getModelcovName(modelcovId);
            infObj.addModel(modelcovId);
        end

        badgeHandler=infObj.initBadgeHandler(modelName,allCovData,options,infObj.covStyleSession);
        displayOnModel(badgeHandler,cvstruct,metricNames,toMetricNames,options,hasFilter);
        cvi.Informer.markHighlightingApplied(modelName,true);
        highlightedModel=modelName;




