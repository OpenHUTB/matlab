



classdef ReportScriptTopSummary<cvi.ReportScriptBase

    properties(Constant,Hidden)
        SIL_MODES={'SIL','ModelRefSIL'}
        PIL_MODES={'PIL','ModelRefPIL'}

        CODECOV_METRIC_NAMES={...
        'decision',...
        'condition',...
        'mcdc',...
        'cvmetric_Structural_relationalop',...
        'cvmetric_Structural_block',...
        'cvmetric_funentry',...
'cvmetric_funcall'...
        }
    end

    properties
options
topModelName
title
cvdatagroups
isCalledFromCvHTMLForCodeCoverage
baseFileName
fileName
allModelsData
        sfcnCovGroup=[]
        silCovGroup=[]
        pilCovGroup=[]
        hasNormalCov=true
        hasSFcnCov=false
        hasSiLCov=false
        hasPiLCov=false
        hasCodeCov=false
        covMode=SlCov.CovMode.Mixed
        isAggregation=false
        forMLCodeCov=false
    end
    methods

        function this=ReportScriptTopSummary(fileName,args)
            this.cvdatagroups={};
            this.isCalledFromCvHTMLForCodeCoverage=false;
            this.fileName=fileName;
            cvhtmlSettings=[];
            for i=1:length(args)
                arg=args{i};

                if isa(arg,'cv.cvdatagroup')
                    this.isAggregation=isa(arg,'cv.aggregation');
                    classType='cv.cvdatagroup';
                else
                    classType=class(arg);
                end
                switch(classType)
                case 'SlCov.CovMode'

                    this.covMode=arg;
                case 'cv.cvdatagroup'
                    this.cvdatagroups{end+1}=arg;
                case 'cv.coder.cvdatagroup'
                    this.cvdatagroups{end+1}=arg;
                case 'cvi.CvhtmlSettings'
                    cvhtmlSettings=arg;
                case 'char'
                    if strcmpi(arg,'calledFromCvHTMLForCodeCoverage')
                        this.isCalledFromCvHTMLForCodeCoverage=true;
                    end
                otherwise

                end
            end

            this.options=cvhtmlSettings;
        end

        function run(this)
            showReport=this.options.showReport;
            this.topModelName=this.options.topModelName;

            get_file_handle(this,this.fileName);

            if~isempty(this.cvdatagroups)
                prepare_data(this);
            end

            if isempty(this.allModelsData)&&~this.hasSFcnCov&&~this.hasCodeCov
                disp(getString(message('Slvnv:simcoverage:cvhtml:ThereIsNoReport')));
            end

            html_start(this);
            report_head(this);
            report_body(this);
            html_end(this);
            if~this.options.mathWorksTesting&&showReport&&this.options.summaryMode==0
                show_report(this);
            end
        end

        function report_body(this)

            printIt(this,'<body>\n');
            printIt(this,'<h1>%s</h1>\n',this.title);
            if~isempty(this.topModelName)
                printIt(this,'<h3>%s</h3>\n',getString(message('Slvnv:simcoverage:cvhtml:TopModel',this.topModelName)));
            end

            if this.hasNormalCov&&~isempty(this.allModelsData)&&(this.hasSFcnCov||this.hasCodeCov)
                printIt(this,'<h4><u>%s:</u></h4>\n',getString(message('Slvnv:simcoverage:cvhtml:ModelCoverageResults')));
            end

            if this.hasNormalCov&&(~isempty(this.allModelsData)||this.hasSFcnCov)
                generate_summary(this);
                generate_code_coverage_summary(this,this.sfcnCovGroup);
                if this.options.summaryMode==0
                    generate_sigrange(this);
                end
            end

            if this.hasCodeCov
                if~isempty(this.silCovGroup)&&hasResults(this.silCovGroup)
                    generate_code_coverage_summary(this,this.silCovGroup,this.SIL_MODES);
                end
                if~isempty(this.pilCovGroup)&&hasResults(this.pilCovGroup)
                    generate_code_coverage_summary(this,this.pilCovGroup,this.PIL_MODES);
                end
            end

            printIt(this,'</body>\n');
        end


        function generate_sigrange(this)

            if isempty(this.allModelsData)||isempty(this.allModelsData.hasSignalRange)
                return;
            end

            numSigRange=numel(this.allModelsData.hasSignalRange);
            sigRangeData=repmat(struct('name','','refFileName',''),1,numSigRange);

            for idx=1:numSigRange
                cmr=this.allModelsData.hasSignalRange{idx};
                sigRangeData(idx).name=cmr.name;
                sigRangeData(idx).refFileName=cmr.refFileName;
            end

            if this.options.isLinked
                ref={'&in_href','#name','#refFileName'};
            else
                ref={'#name'};
            end

            script={{'ForEach','#.',...
            {'CellFormat'...
            ,ref,...
1...
            ,'$"left"'...
            }...
            ,'\n'...
            }};

            systableInfo.cols.align='"center"';
            systableInfo.table='rules="groups" cellpadding="2" cellspacing="1"';
            systableInfo.textSize=2;
            systableInfo.imageDir=this.options.imageSubDirectory;
            systableInfo.twoColorBarGraphs=this.options.twoColorBarGraphs;
            systableInfo.barGraphBorder=this.options.barGraphBorder;

            tableStr=cvprivate('html_table',sigRangeData,script,systableInfo);
            printIt(this,'<h4>%s:</h4>\n',getString(message('Slvnv:simcoverage:cvhtml:ModelsHaveSignalRange')));
            printIt(this,'%s',tableStr);

        end

        function allModels=computeTotal(this,allModels)
            allMetricNames=this.getCombinedEnabledMetricNames(allModels);
            for idx=1:allModels.testNum
                for j=1:length(allMetricNames)
                    mn=allMetricNames{j};
                    totalHits=0;
                    totalCnt=0;
                    justifiedTotalHits=0;
                    anyHasMetric=false;
                    for i=1:length(allModels.mdlref)
                        if~isempty(allModels.mdlref(i).test)&&...
                            isfield(allModels.mdlref(i).test(idx),mn)

                            anyHasMetric=true;
                            if~isempty(allModels.mdlref(i).test(idx).(mn))
                                d=allModels.mdlref(i).test(idx).(mn);
                                totalHits=totalHits+d.totalHits;
                                justifiedTotalHits=justifiedTotalHits+d.justifiedTotalHits;
                                totalCnt=totalCnt+d.totalCnt;
                            end
                        end
                    end
                    if totalCnt>0
                        allModels.test(idx).(mn).totalHits=totalHits;
                        allModels.test(idx).(mn).justifiedTotalHits=justifiedTotalHits;
                        allModels.test(idx).(mn).totalCnt=totalCnt;
                        allModels.test(idx).(mn).executedIn='';
                    elseif anyHasMetric

                        allModels.test(idx).(mn)=[];
                    end
                end
            end
        end




        function[metricTitles,metricData]=create_metric_data(this,metricNames,options,colspan,forSFunOrCode)

            metricTitles={};
            metricData={};
            for idx=1:length(metricNames)
                mn=metricNames{idx};
                if forSFunOrCode&&strcmp(mn,'cvmetric_Structural_block')

                    mtitle=getString(message('Slvnv:simcoverage:cvhtml:SFcnStatement'));
                elseif strcmp(mn,'cvmetric_funentry')
                    mtitle=getString(message('Slvnv:simcoverage:cvhtml:SFcnFunction'));
                elseif strcmp(mn,'cvmetric_funcall')
                    mtitle=getString(message('Slvnv:simcoverage:cvhtml:SFcnFunCall'));
                else
                    mtitle=cvi.MetricRegistry.getShortMetricTxt(mn,options);
                end
                metricTitles=add_metric_title(this,metricTitles,mtitle,colspan);
                metricData=add_metric_data(this,metricData,mn,options,colspan);
            end
        end

        function allModels=order_data(~,allModels)
            if~isempty(allModels.metricNames)
                mn=allModels.metricNames{1};
            else
                mn=allModels.toMetricNames{1};
            end
            perc=zeros(1,length(allModels.mdlref));
            for idx=1:length(allModels.mdlref)
                if~isempty(allModels.mdlref(idx).test)&&~isempty(allModels.mdlref(idx).test(1).(mn))
                    d=allModels.mdlref(idx).test(1).(mn)(1);
                    perc(idx)=double(d.totalHits+d.justifiedTotalHits)/d.totalCnt;
                else
                    perc(idx)=100;
                end
            end
            [~,sidx]=sort(perc);
            allModels.mdlref=allModels.mdlref(sidx);
        end

        function metricData=add_metric_data(~,metricData,metric_name,options,colspan)
            metric_field=['#',metric_name];
            barGr={};
            if options.barGrInMdlSumm
                barGr={{'&in_bargraph',[metric_field,'.totalHits'],[metric_field,'.justifiedTotalHits'],[metric_field,'.totalCnt'],'@2'}};
            end


            if options.hitCntInMdlSumm
                metDispFcn='&in_covperratios';
            else
                metDispFcn='&in_covpercent';
            end

            metricData=[metricData,...
            {{'Cat','$&#160;&#160;'},...
            {'If',{'&isempty',metric_field},...
            {'CellFormat','$--',colspan},...
            'Else',...
            {metDispFcn,[metric_field,'.totalHits'],...
            [metric_field,'.justifiedTotalHits'],...
            [metric_field,'.totalCnt'],...
            '@2'},...
            barGr{:}...
            }}];%#ok<*CCAT>
        end

        function metricTitles=add_metric_title(~,metricTitles,title,colspan)
            metricTitles=[metricTitles,{{'Cat','$&#160;&#160;'},{'CellFormat',['$',title],colspan}}];
        end

        function generate_code_coverage_summary(this,codeCovDataGroup,modeNames)

            forSFcnCov=true;
            if nargin>2
                forSFcnCov=false;
            end

            if isempty(codeCovDataGroup)||~hasResults(codeCovDataGroup)
                return
            end

            sfThis=this;

            cvdgs=this.cvdatagroups;


            metricNames=this.CODECOV_METRIC_NAMES;

            idx=true(size(metricNames));


            if this.options.filtExecMetric
                idx(strcmp(metricNames,'cvmetric_Structural_block'))=false;
            end
            if forSFcnCov
                idx(strcmp(metricNames,'cvmetric_funentry'))=false;
                idx(strcmp(metricNames,'cvmetric_funcall'))=false;
            end
            metricNames(~idx)=[];

            if isempty(metricNames)
                return
            end

            if forSFcnCov
                printIt(this,'<br/>\n');
                printIt(this,'<h4><u>%s:</u></h4>\n',getString(message('Slvnv:simcoverage:cvhtml:SFcnCoverageResults')));
            elseif~isempty(sfThis.allModelsData)
                if this.hasNormalCov
                    printIt(this,'<br/>\n');
                end
                printIt(this,'<h4><u>%s:</u></h4>\n',getString(message('Slvnv:simcoverage:cvhtml:CodeCoverageResults',modeNames{1})));
            end


            hasNoModel=isempty(sfThis.allModelsData);
            sfThis.allModelsData.metricNames=metricNames;
            sfThis.allModelsData.toMetricNames={};
            sfThis.allModelsData.hasSignalRange={};
            if hasNoModel
                sfThis.allModelsData.testNum=numel(cvdgs);

                if this.options.cumulativeReport
                    sfThis.allModelsData.testTitle={...
                    getString(message('Slvnv:simcoverage:cvhtml:CurrentRun')),...
                    getString(message('Slvnv:simcoverage:cvhtml:Delta')),...
                    getString(message('Slvnv:simcoverage:cvhtml:Cumulative'))};
                else
                    if numel(cvdgs)==1
                        sfThis.allModelsData.testTitle{1}=sprintf('Test');
                    else
                        for idx=1:numel(cvdgs)
                            sfThis.allModelsData.testTitle{idx}=sprintf('Test %d',idx);
                        end
                    end
                    if this.options.allTestInMdlSumm
                        sfThis.allModelsData.testTitle{end}='Total';
                    end
                end

                [sfThis.allModelsData.enabledMetricNames,...
                sfThis.allModelsData.enabledTOMetricNames]=this.getEnabledMetricNames();
            else
                if isfield(sfThis.allModelsData,'mdlref')
                    sfThis.allModelsData=rmfield(sfThis.allModelsData,'mdlref');
                end
            end

            numMetrics=numel(metricNames);
            metricResultVal=struct('totalHits',0,'totalCnt',0);



            allCodeCovGroupPerTest=cell(numel(cvdgs),1);
            allCodeCovGroupPerTest{1}=codeCovDataGroup;
            for ii=2:numel(cvdgs)
                if forSFcnCov
                    allCodeCovGroupPerTest{ii}=getAllCodeCovGrp(this,cvdgs{ii});
                else
                    allCodeCovGroupPerTest{ii}=getAllCodeCovGrp(this,cvdgs{ii},modeNames);
                end
            end


            allCodeCovResNames=codeCovDataGroup.allNames();
            modelName2NumModes=containers.Map('KeyType','char','ValueType','any');
            if~forSFcnCov
                for ii=1:numel(allCodeCovResNames)
                    moduleName=SlCov.coder.EmbeddedCoder.parseModuleName(allCodeCovResNames{ii});
                    if modelName2NumModes.isKey(moduleName)
                        val=modelName2NumModes(moduleName);
                    else
                        val=0;
                    end
                    modelName2NumModes(moduleName)=val+1;
                end
            end

            baseDir=fileparts(this.baseFileName);

            if this.options.summaryMode<1
                cvi.ReportUtils.prepareImageFiles(baseDir);
            end

            badIdx=true(1,numel(metricNames));
            for ii=1:numel(allCodeCovResNames)
                if isfield(sfThis.allModelsData,'mdlref')
                    res=sfThis.allModelsData.mdlref(end);
                else
                    res=struct();
                end

                args={};
                codeCovRes=codeCovDataGroup.get(allCodeCovResNames{ii});

                if this.options.summaryMode<1
                    args{1}=codeCovRes;
                    for jj=2:numel(cvdgs)

                        codeCovGrp=allCodeCovGroupPerTest{jj};

                        if~isempty(codeCovGrp)&&hasResults(codeCovGrp)
                            tmp=codeCovGrp.get(allCodeCovResNames{ii});
                            if~isempty(tmp)&&hasResults(tmp)
                                args=[args,{tmp}];%#ok<AGROW>
                            end
                        end
                    end

                    if forSFcnCov
                        args=[args,{'radixName',[this.topModelName,'_',codeCovRes.Name,'_all']}];%#ok<AGROW>
                    else
                        radixName=[regexprep(codeCovRes.Name,'\W','_'),'_(',lower(char(codeCovRes.Mode)),')'];
                        args=[args,{'radixName',radixName}];%#ok<AGROW>
                    end


                    args=[args,{...
                    this.options,...
                    'showReport',false,...
                    'outputDir',baseDir,...
                    'lastIsTotal',true,...
                    'metricNames',metricNames,...
                    'scriptsection',cvi.ReportUtils.getJScriptSection(),...
                    'topMostModelName',this.topModelName...
                    }];%#ok<AGROW>

                    htmlFiles={};

                    if(codeCovRes.getNumInstances()==1)
                        htmlFile=codeCovRes.getHtmlFile(1);
                        if~isempty(htmlFile)
                            htmlFiles={htmlFile};
                        end
                    end
                    if isempty(htmlFiles)
                        htmlFiles=codeinstrum.internal.codecov.CodeCovData.htmlReport(args{:});
                    end

                    if isempty(htmlFiles)
                        continue
                    elseif~forSFcnCov
                        cvd=cvdgs{1}.get(codeCovRes.Name,codeCovRes.Mode);
                        if~this.forMLCodeCov
                            baseReportName=htmlFiles{1};
                            modelcovId=cv('get',cvd.rootID,'.modelcov');
                            cv('set',modelcovId,'modelcov.currentDisplay.baseReportName',baseReportName);
                        end
                    end
                end

                res.name=codeCovRes.Name;
                res.unmangledName=res.name;
                res.covMode=codeCovRes.Mode;
                if~forSFcnCov&&...
                    (codeCovRes.Mode==SlCov.CovMode.SIL||codeCovRes.Mode==SlCov.CovMode.PIL)


                    if~modelName2NumModes.isKey(res.name)||modelName2NumModes(res.name)>1
                        res.name=[res.name,' (',modeNames{1},': Top)'];
                    end
                end

                if this.options.summaryMode<1
                    res.refFileName=cvi.ReportUtils.file_path_2_url(htmlFiles{1});
                else
                    res.refFileName='#';
                end

                allInfo=cell2struct(repmat({metricResultVal},1,numMetrics),metricNames,2);


                cycloCplx=[];
                for jj=1:numel(cvdgs)

                    codeCovGrp=allCodeCovGroupPerTest{jj};

                    codeCovData=[];
                    aggRes=[];
                    if~isempty(codeCovGrp)
                        codeCovData=codeCovGrp.get(allCodeCovResNames{ii});
                        if~isempty(codeCovData)
                            aggRes=codeCovData.getAggregatedResults();
                            cycloCplx=codeCovData.CodeTr.getCycloCplx(codeCovData.CodeTr.Root);
                            cycloCplx=cycloCplx(1);
                        end
                    end

                    testInfo=cell2struct(repmat({metricResultVal},1,numMetrics),metricNames,2);
                    for kk=1:numMetrics
                        fName=metricNames{kk};
                        if isempty(codeCovData)
                            testInfo.(fName)=[];
                        else
                            metricKind=codeinstrum.internal.codecov.CodeCovData.getCodeCovResStructInfoForMetric(fName);
                            stats=aggRes.getDeepMetricStats(codeCovData.CodeTr.Root,metricKind);
                            if stats.metricKind~=internal.cxxfe.instrum.MetricKind.UNKNOWN
                                testInfo.(fName).totalHits=double(stats.numCovered);
                                testInfo.(fName).justifiedTotalHits=double(stats.numJustifiedUncovered);
                                testInfo.(fName).totalCnt=double(stats.numNonExcluded);
                                testInfo.(fName).executedIn='';
                                if testInfo.(fName).totalCnt~=0
                                    badIdx(kk)=false;
                                else
                                    testInfo.(fName)=[];
                                end
                            else
                                testInfo.(fName)=[];
                            end
                        end
                    end

                    allInfo(jj)=testInfo;
                end

                if~isempty(cycloCplx)
                    res.complexity=cycloCplx;
                else
                    res.complexity=0;
                end

                res.test=allInfo;
                if isfield(sfThis.allModelsData,'mdlref')
                    sfThis.allModelsData.mdlref(end+1)=res;
                else
                    sfThis.allModelsData.mdlref=res;
                end
            end




            sfThis.allModelsData.metricNames(badIdx)=[];

            generate_summary(sfThis,true,forSFcnCov);
        end

        function allModels=add_summary_group(this,allModels,grpName,grpIdx,grpResults)


            currGroup=allModels;
            currGroup.mdlref=grpResults;
            currGroup=computeTotal(this,currGroup);


            grpItem=struct(...
            'name',grpName,...
            'unmangledName',grpName,...
            'covMode',SlCov.CovMode.Normal,...
            'refFileName','',...
            'complexity',sum([currGroup.mdlref.complexity]),...
            'test',currGroup.test,...
            'num',grpIdx,...
            'subnum',0,...
            'level',1,...
            'skipref',1...
            );


            for ii=1:numel(currGroup.mdlref)
                currGroup.mdlref(ii).num=grpIdx;
                currGroup.mdlref(ii).subnum=ii;
                currGroup.mdlref(ii).level=2;
                currGroup.mdlref(ii).skipref=0;
            end


            allModels.mdlref=[allModels.mdlref(:);grpItem;currGroup.mdlref(:)];
        end

        function generate_summary(this,forSFunOrCode,forSFcnCov)

            if nargin<2
                forSFunOrCode=false;
            end
            if nargin<3
                forSFcnCov=false;
            end

            if isempty(this.allModelsData)||...
                (isempty(this.allModelsData.metricNames)&&isempty(this.allModelsData.toMetricNames))
                return;
            end

            allModels=order_data(this,this.allModelsData);
            allModels=computeTotal(this,allModels);
            testNum=allModels.testNum;


            groupByFamily=false;
            if~forSFcnCov&&...
                (forSFunOrCode||SlCov.isSLCustomCodeCovFeatureOn())

                idxMdl=[];
                idxExtFile=[];
                idxSimCustomCode=[];
                idxSharedUtil=[];
                idxCustomCode=[];
                idxObserver=[];
                idxAccel=[];
                cvdg=this.cvdatagroups{1};
                for ii=1:numel(allModels.mdlref)
                    cvds=cvdg.get(allModels.mdlref(ii).unmangledName,allModels.mdlref(ii).covMode);
                    for idx=1:numel(cvds)
                        cvd=cvds(idx);
                        if~isempty(cvd)
                            if cvd.isExternalMATLABFile
                                idxExtFile=[idxExtFile,ii];%#ok<AGROW>
                            elseif cvd.isSimulinkCustomCode
                                idxSimCustomCode=[idxSimCustomCode,ii];%#ok<AGROW>
                            elseif cvd.isSharedUtility
                                idxSharedUtil=[idxSharedUtil,ii];%#ok<AGROW>
                            elseif cvd.isCustomCode
                                idxCustomCode=[idxCustomCode,ii];%#ok<AGROW>
                            elseif cvd.isObserver
                                idxObserver=[idxObserver,ii];%#ok<AGROW>
                            elseif cvd.simMode==SlCov.CovMode.Accel
                                idxAccel=[idxAccel,ii];%#ok<AGROW>
                            else
                                idxMdl=[idxMdl,ii];%#ok<AGROW>
                            end
                        end
                    end
                end


                numPerGroup=[numel(idxMdl),numel(idxExtFile),numel(idxSimCustomCode),numel(idxSharedUtil),numel(idxCustomCode),numel(idxObserver),numel(idxAccel)];
                groupByFamily=numel(find(numPerGroup))>1;


                if groupByFamily

                    allResults=allModels.mdlref;
                    allModels.mdlref=[];


                    grpIdx=0;


                    if~isempty(idxMdl)
                        if isempty(idxObserver)
                            grpName=getString(message('Slvnv:simcoverage:cvhtml:ModelGrpLabel'));
                        else
                            grpName=getString(message('Slvnv:simcoverage:cvhtml:DesignModelGrpLabel'));
                        end
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxMdl));
                    end
                    if~isempty(idxExtFile)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:ExtMATLABFileGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxExtFile));
                    end
                    if~isempty(idxSimCustomCode)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:CustomCodeGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxSimCustomCode));
                    end
                    if~isempty(idxSharedUtil)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:SharedUtilitiesGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxSharedUtil));
                    end
                    if~isempty(idxCustomCode)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:CustomCodeGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxCustomCode));
                    end
                    if~isempty(idxObserver)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:ObserverModelGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxObserver));
                    end
                    if~isempty(idxAccel)
                        grpName=getString(message('Slvnv:simcoverage:cvhtml:AccelModelGrpLabel'));
                        grpIdx=grpIdx+1;
                        allModels=add_summary_group(this,allModels,grpName,grpIdx,allResults(idxAccel));
                    end

                end
            end

            colspan=1+int8(this.options.barGrInMdlSumm);

            tmpMetricNames=fields(allModels.test);
            if forSFunOrCode


                hasMetric=ismember(this.CODECOV_METRIC_NAMES,tmpMetricNames);
                tmpMetricNames=this.CODECOV_METRIC_NAMES(hasMetric);
            end

            if this.options.filtExecMetric
                tmpMetricNames=setdiff(tmpMetricNames,'cvmetric_Structural_block');
            end

            [metricTitles,metricData]=create_metric_data(this,tmpMetricNames,this.options,colspan,forSFunOrCode);

            complexD={};
            if this.options.complexInSumm
                complexD={{'Cat','#complexity'}};
            end
            space={'Cat','$&#160;&#160;'};
            columnData={'ForEach','#test',space,metricData{:}};

            if groupByFamily
                if this.options.isLinked
                    rowTocEntry={'&in_tocentry',{'&in_href','#name','#refFileName','#skipref'},'#num','#level','#subnum'};
                else
                    rowTocEntry={'&in_tocentry','#name','#num','#level','#subnum'};
                end
            else
                if this.options.isLinked
                    rowTocEntry={'&in_tocentry',{'&in_href','#name','#refFileName'},'@1',1};
                else
                    rowTocEntry={'&in_tocentry','#name','@1',1};
                end
            end
            rowEntries={'ForEach','#mdlref',...
            {'CellFormat',...
            rowTocEntry,...
            1,...
'$"left"'...
            },...
            complexD{:}...
            ,columnData,...
'\n'...
            };


            if this.options.complexInSumm
                complexMH={space,{'CellFormat',['$',getString(message('Slvnv:simcoverage:cvhtml:Complexity'))],1}};
            else
                complexMH={space};
            end
            metricHeader={complexMH{:}...
            ,{'ForN',testNum,space,metricTitles{:}}...
            };
            complexTH={};
            if this.options.complexInSumm
                complexTH={space};
            end

            totalRow={{'CellFormat',['$','<b>',getString(message('Slvnv:simcoverage:cvhtml:TotalCoverage')),'</b>'],1}...
            ,complexTH{:}...
            ,columnData...
            };

            if testNum>1

                metricCount=numel(tmpMetricNames);
                testColSpan=(colspan+1)*metricCount;
                testHeaderCore={space,space,space};

                for idx=1:testNum
                    testHeaderCore=[testHeaderCore,{space,{'CellFormat',['$',allModels.testTitle{idx}],testColSpan}}];%#ok<AGROW>
                end

                testHeader={...
                {'CellFormat','$',testColSpan}...
                ,testHeaderCore{:}...
                };
                script={...
                testHeader{:}...
                ,'\n'...
                ,metricHeader{:}...
                ,'\n'};

            else
                script={...
                metricHeader{:}...
                ,'\n'...
                };
            end
            script=['<thead>',script,'</thead>',{...
'$&#160;'...
            ,'\n'...
            ,totalRow{:}...
            ,'\n'...
            ,'$&#160;'...
            ,'\n'...
            ,rowEntries...
            }];

            systableInfo.cols.align='"center"';
            systableInfo.table='rules="groups" frame = "above" cellpadding="2" cellspacing="1"';
            systableInfo.textSize=2;
            systableInfo.imageDir=this.options.imageSubDirectory;
            systableInfo.twoColorBarGraphs=this.options.twoColorBarGraphs;
            systableInfo.barGraphBorder=this.options.barGraphBorder;

            tableStr=cvprivate('html_table',allModels,script,systableInfo);
            printIt(this,'%s',tableStr);
        end


        function show_report(this)
            browserLoc=this.baseFileName;

            hBrowser=cvprivate('local_browser_mgr','displayFile',browserLoc);
            if~isempty(hBrowser)

                htmlData=[];
                cvprivate('html_info_mgr','load',browserLoc,htmlData);

            else
                disp(getString(message('Slvnv:simcoverage:cvhtml:UnableToOpenCoverageReport')));
            end
        end

        function get_file_handle(this,fileName)
            [path,name,ext]=cvi.ReportUtils.getFilePartsWithWriteChecks(fileName,'.html');
            this.baseFileName=fullfile(path,append(name,ext));
            this.openFile(this.baseFileName);
        end

        function report_head(this)

            printIt(this,'<head>\n');
            printIt(this,'%s\n',cvi.ReportUtils.getJScriptSection());
            if this.forMLCodeCov||(this.hasCodeCov&&isempty(this.allModelsData)&&~this.hasSFcnCov)
                if this.hasSiLCov&&this.hasPiLCov
                    mode='SIL/PIL';
                elseif this.hasPiLCov
                    mode='PIL';
                else
                    mode='SIL';
                end
                if this.forMLCodeCov
                    this.title=getString(message('Slvnv:simcoverage:cvhtml:CodeCoverageReportByModule',mode));
                else
                    this.title=getString(message('Slvnv:simcoverage:cvhtml:CodeCoverageReportByModel',mode));
                end
            else
                this.title=getString(message('Slvnv:simcoverage:cvhtml:CoverageReportByModel'));
            end

            printIt(this,'<meta http-equiv="Content-Type" content="text/html; charset=utf-8"></meta> \n');
            printIt(this,'<title> %s </title>\n',this.title);
            printIt(this,'</head>\n');
            printIt(this,'\n');

        end

        function html_start(this)
            printIt(this,'<html>\n');
        end

        function html_end(this)
            printIt(this,'</html>\n');
            this.closeFile;
        end



        function[mdlref,hasSignalRange]=reshape_data(this,allModels,cvstruct,emptyTestIdx,baseFileDir)

            hasSignalRange=[];
            [mn,filename]=this.getModelFileName(cvstruct);
            mdlref.name=mn;
            mdlref.unmangledName=mn;
            mdlref.covMode=cvstruct.mode;
            radixName=filename;
            if isfield(allModels.renamedModels,filename)
                radixName=allModels.renamedModels.(filename);
            end
            refFileName=cvi.ReportUtils.get_report_file_name(radixName,'reproduce',1,'filedir',baseFileDir);
            mdlref.refFileName=cvi.ReportUtils.file_path_2_url(refFileName);

            if isfield(cvstruct,'system')&&~isempty(cvstruct.system)
                mdlref.complexity=cvstruct.system.complexity.deep;
            else
                mdlref.complexity=0;
            end

            allMetricNames=this.getCombinedEnabledMetricNames(allModels);
            for j=1:length(allMetricNames)
                mn=allMetricNames{j};
                totalHits=[];
                if isfield(cvstruct,'system')&&~isempty(cvstruct.system)&&...
                    isfield(cvstruct.system,mn)&&~isempty(cvstruct.system.(mn))
                    switch mn
                    case 'decision'
                        totalHits=cvstruct.system.(mn).outTotalCnts;
                        totalCnt=cvstruct.system.(mn).totalTotalCnts;
                        justifiedTotalHits=cvstruct.system.(mn).justifiedOutTotalCnts;
                    case{'condition','mcdc','tableExec'}
                        totalHits=cvstruct.system.(mn).totalHits;
                        totalCnt=cvstruct.system.(mn).totalCnt;
                        justifiedTotalHits=cvstruct.system.(mn).justifiedTotalHits;
                    case{'sigrange','sigsize'}
                    otherwise
                        if isfield(cvstruct.system,mn)
                            totalHits=cvstruct.system.(mn).outTotalCnts;
                            totalCnt=cvstruct.system.(mn).totalTotalCnts;
                            justifiedTotalHits=cvstruct.system.(mn).justifiedOutTotalCnts;
                        end
                    end
                end

                if~isempty(totalHits)
                    c=1;
                    for i=1:allModels.testNum
                        if isKey(emptyTestIdx,mdlref.name)&&...
                            ~isempty(emptyTestIdx(mdlref.name))&&any(emptyTestIdx(mdlref.name)==i)
                            mdlref.test(i).(mn)=[];
                        else
                            if c>numel(totalHits)
                                mdlref.test(i).(mn)=[];
                            else
                                mdlref.test(i).(mn).totalHits=totalHits(c);
                                mdlref.test(i).(mn).justifiedTotalHits=justifiedTotalHits(c);
                                mdlref.test(i).(mn).totalCnt=totalCnt;
                                mdlref.test(i).(mn).executedIn='';
                                c=c+1;
                            end
                        end

                    end
                else
                    for i=1:allModels.testNum
                        mdlref.test(i).(mn)=[];
                    end
                end
                if isequal(mn,'sigrange')&&...
                    ~isempty(cvstruct.allCvData{1}.modelinfo.modelVersion)
                    hasSignalRange.name=mdlref.name;
                    hasSignalRange.refFileName=mdlref.refFileName;
                end
            end

        end


        function metricNames=order_metric_names(~,metricNames)

            rightOrder={'decision','condition','mcdc','tableExec','sigrange','sigsize'};
            [~,oI]=intersect(rightOrder,metricNames);
            metricNames=rightOrder(sort(oI));
        end


        function mdlCovInfo=getSimCustomCodeCoverageInfo(this,allCvData,mdlCovInfo,filterCtx)

            allMetrics=fieldnames(mdlCovInfo.test);
            for ii=1:numel(mdlCovInfo.test)


                if numel(allCvData)<ii||isempty(allCvData{ii})
                    continue
                end
                codeCovRes=allCvData{ii}.sfcnCovData;
                if isempty(codeCovRes)||~hasResults(codeCovRes)
                    return
                end
                codeCovRes=codeCovRes.getAll();
                filterCtx.cvdataId=allCvData{ii}.id;
                filterCtx.appliedFilters=cv('get',allCvData{ii}.rootId,'.filterApplied');
                codeCovData=codeCovRes(1);
                codeCovData.setFilterCtx(filterCtx);
                res=codeCovData.getAggregatedResults();
                numCyclo=codeCovData.CodeTr.getCycloCplx(codeCovData.CodeTr.Root);
                mdlCovInfo.complexity=numCyclo(1);

                for jj=1:numel(allMetrics)
                    mn=allMetrics{jj};
                    [numHits,numTot,numJustif]=getTotalCoverage(mn);
                    if numTot>0
                        mdlCovInfo.test(ii).(mn).totalHits=numHits;
                        mdlCovInfo.test(ii).(mn).justifiedTotalHits=numJustif;
                        mdlCovInfo.test(ii).(mn).totalCnt=numTot;
                        mdlCovInfo.test(ii).(mn).executedIn='';
                    else
                        mdlCovInfo.test(ii).(mn)=[];
                    end
                end
            end

            function[totalHits,totalCnt,justifiedTotalHits]=getTotalCoverage(metricName)

                totalHits=0;
                totalCnt=0;
                justifiedTotalHits=0;


                metricKind=codeinstrum.internal.codecov.CodeCovData.getCodeCovResStructInfoForMetric(metricName);
                if isempty(metricKind)
                    return
                end


                stats=res.getDeepMetricStats(codeCovData.CodeTr.Root,metricKind);
                totalHits=double(stats.numCovered);
                justifiedTotalHits=double(stats.numJustifiedUncovered);
                totalCnt=double(stats.numNonExcluded);
            end
        end

        function[mn,filename]=getModelFileName(this,cvstruct)

            cvd=cvstruct.allCvData{1};
            if this.isAggregation
                mn=cvd.modelinfo.analyzedModel;
                filename=replace(mn,'/','_');
                filename=replace(filename,newline,'_');
                filename=replace(filename,' ','_');
            else
                mn=cvstruct.model.name;
                filename=mn;
            end
        end

        function prepare_data(this)

            allMdlNames={};
            this.allModelsData=[];
            moreThanOneTestProvided=length(this.cvdatagroups)>1&&this.options.allTestInMdlSumm&&~this.options.cumulativeReport;
            firstCvdg=this.cvdatagroups{1};
            if moreThanOneTestProvided
                total=firstCvdg;
                allNormalNames={};
                for cidx=1:length(this.cvdatagroups)
                    ccvdg=this.cvdatagroups{cidx};
                    total=total+ccvdg;
                    allNormalNames=[allNormalNames,ccvdg.allNames(SlCov.CovMode.Normal)'];%#ok<AGROW>
                end
                this.cvdatagroups{end+1}=total;
                allNormalNames=unique(allNormalNames);
                allMdlNames=struct('name',allNormalNames,'mode',SlCov.CovMode.Normal);

            else
                allNormalNames=firstCvdg.allNames(SlCov.CovMode.Normal)';
                allMdlNames=struct('name',allNormalNames,'mode',SlCov.CovMode.Normal);
                allAccelNames=firstCvdg.allNames(SlCov.CovMode.Accel)';
                allMdlNames=[allMdlNames,struct('name',allAccelNames,'mode',SlCov.CovMode.Accel)];
            end

            allModels.metricNames={};
            allModels.toMetricNames={};
            allModels.enabledMetricNames={};
            allModels.enabledTOMetricNames={};
            allModels.renamedModels=[];
            cvstructs={};
            emptyTestIdx=containers.Map('KeyType','char','ValueType','any');
            for idx=1:numel(allMdlNames)
                cmn=allMdlNames(idx).name;
                mode=allMdlNames(idx).mode;

                allCvData={};
                emptyTestIdx(cmn)=[];
                testIds={};
                for cidx=1:length(this.cvdatagroups)
                    dg=this.cvdatagroups{cidx};
                    cvd=dg.get(cmn,mode);
                    if~isempty(cvd)
                        [metricNames,toMetricNames]=cvi.ReportUtils.get_all_metric_names(cvd);
                        allCvData{end+1}=cvd;%#ok<AGROW>
                        testIds{end+1}=cvd.id;%#ok<AGROW>
                    end
                end


                if~isempty(allCvData)
                    tmpMetricNames=setdiff(metricNames,{'sigrange','sigsize'});
                    if~this.options.cumulativeReport&&numel(testIds)>1
                        testIds(end)=[];
                    end
                    cvstruct=cvprivate('report_create_structured_data',allCvData,testIds,tmpMetricNames,toMetricNames,this.options,[],true);

                    allModels.metricNames=union(allModels.metricNames,metricNames,'legacy');
                    allModels.toMetricNames=union(allModels.toMetricNames,toMetricNames,'legacy');
                    allModels.enabledMetricNames=union(allModels.enabledMetricNames,cvstruct.enabledMetricNames,'legacy');
                    allModels.enabledTOMetricNames=union(allModels.enabledTOMetricNames,cvstruct.enabledTOMetricNames,'legacy');
                    cvstruct.mode=mode;
                    cvstructs{idx}=cvstruct;%#ok<AGROW>
                    [~,filename]=this.getModelFileName(cvstruct);
                    [baseFileDir,~,~]=fileparts(this.baseFileName);
                    refFileName=cvi.ReportUtils.get_report_file_name(filename,'filedir',baseFileDir);
                    store.showReport=this.options.showReport;
                    store.summaryMode=this.options.summaryMode;
                    this.options.showReport=false;

                    if(moreThanOneTestProvided)
                        icvdg=allCvData(1:end-1);
                    else
                        icvdg=allCvData;
                    end
                    if strcmpi(refFileName,this.baseFileName)


                        newName=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(filename,{allMdlNames.name}));
                        refFileName=cvi.ReportUtils.get_report_file_name(newName,'filedir',baseFileDir);
                        allModels.renamedModels.(filename)=newName;
                    end
                    cvhtml(refFileName,icvdg{:},this.options,'calledFromCvHTMLDataGroup');
                    this.options.showReport=store.showReport;

                end
            end


            this.sfcnCovGroup=[];
            if~isempty(allMdlNames)
                codeCovGroup=getAllCodeCovGrp(this,firstCvdg);



                allCodeCov=codeCovGroup.getAll();
                hasRes=false;
                for ii=1:numel(allCodeCov)
                    codeCovData=allCodeCov(ii);
                    for jj=1:codeCovData.getNumInstances()
                        if~isempty(codeCovData.getHtmlFile(jj))
                            hasRes=true;
                            break
                        end
                    end
                    if hasRes
                        break
                    end
                end
                if hasRes
                    this.sfcnCovGroup=codeCovGroup;
                end
            end
            this.hasSFcnCov=~isempty(this.sfcnCovGroup)&&hasResults(this.sfcnCovGroup);

            this.silCovGroup=[];
            this.pilCovGroup=[];
            if ismember(this.covMode,[SlCov.CovMode.Mixed,SlCov.CovMode.getGeneratedCodeValues()])
                this.silCovGroup=getAllCodeCovGrp(this,firstCvdg,this.SIL_MODES);
                this.pilCovGroup=getAllCodeCovGrp(this,firstCvdg,this.PIL_MODES);
            end
            this.hasSiLCov=~isempty(this.silCovGroup)&&hasResults(this.silCovGroup);
            this.hasPiLCov=~isempty(this.pilCovGroup)&&hasResults(this.pilCovGroup);
            this.hasCodeCov=this.hasSiLCov||this.hasPiLCov;
            this.hasNormalCov=ismember(this.covMode,[SlCov.CovMode.Mixed,SlCov.CovMode.Normal]);

            if~isempty(allModels.metricNames)||~isempty(allModels.toMetricNames)
                allModels.testNum=length(this.cvdatagroups);
                allModels.hasSignalRange={};

                for idx=1:length(cvstructs)
                    if~isempty(cvstructs{idx})
                        [mdlref,hasSignalRange]=reshape_data(this,allModels,cvstructs{idx},emptyTestIdx,baseFileDir);
                        if~isempty(hasSignalRange)
                            allModels.hasSignalRange{end+1}=hasSignalRange;
                        end
                        if~isempty(mdlref)
                            if~isfield(allModels,'mdlref')
                                allModels.mdlref(1)=mdlref;
                            else
                                allModels.mdlref(end+1)=mdlref;
                            end


                            isSimCustomCode=isfield(cvstructs{idx},'allCvData')&&...
                            ~isempty(cvstructs{idx}.allCvData)&&...
                            cvstructs{idx}.allCvData{1}.isSimulinkCustomCode();
                            if isSimCustomCode

                                [filterCtxId,reportViewCmd]=this.options.getFilterCtxId();
                                filterCtx.filterCtxId=filterCtxId;
                                filterCtx.reportViewCmd=reportViewCmd;

                                allModels.mdlref(end)=getSimCustomCodeCoverageInfo(this,cvstructs{idx}.allCvData,allModels.mdlref(end),filterCtx);
                            end
                        end
                    end
                end
                allModels.metricNames=setdiff(allModels.metricNames,{'sigrange','sigsize'});
                allModels.metricNames=order_metric_names(this,allModels.metricNames);
                allModels.enabledMetricNames=order_metric_names(this,allModels.enabledMetricNames);

                if~isempty(allModels.metricNames)||~isempty(allModels.toMetricNames)
                    if this.options.cumulativeReport
                        allModels.testTitle={...
                        getString(message('Slvnv:simcoverage:cvhtml:CurrentRun')),...
                        getString(message('Slvnv:simcoverage:cvhtml:Delta')),...
                        getString(message('Slvnv:simcoverage:cvhtml:Cumulative'))};
                    else
                        if isempty(allModels.mdlref)
                            allModels.testTitle{1}=sprintf('Test');
                        else
                            for idx=1:length(allModels.mdlref(1).test)
                                allModels.testTitle{idx}=sprintf('Test %d',idx);
                            end
                        end
                        if this.options.allTestInMdlSumm
                            allModels.testTitle{end}='Total';
                        end
                    end
                end
                this.allModelsData=allModels;
            end
        end

        function allCodeCovGrp=getAllCodeCovGrp(this,cvdg,modeNames)

            if nargin<3
                forSFcnCov=true;
            else
                forSFcnCov=false;
            end

            allCodeCovGrp=SlCov.results.CodeCovDataGroup();

            if forSFcnCov
                allCvds=cvdg.getAll(this.covMode);
                for ii=1:numel(allCvds)
                    cvd=cvdata(allCvds{ii});

                    codeCovGrp=cvd.sfcnCovData;
                    if isempty(codeCovGrp)||~hasResults(codeCovGrp)
                        continue
                    end


                    allSFcnCovData=codeCovGrp.getAll();
                    if allSFcnCovData(1).Mode==SlCov.CovMode.SLCustomCode
                        continue
                    end




                    codeCovGrp=clone(codeCovGrp);
                    cvds=codeCovGrp.getAll();
                    for jj=1:numel(cvds)
                        cvds(jj).setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(this.options,cvd));
                    end

                    if isempty(allCodeCovGrp)||~hasData(allCodeCovGrp)
                        allCodeCovGrp=codeCovGrp;
                        continue
                    end


                    allCodeCovGrp=allCodeCovGrp+codeCovGrp;
                end
            else
                for ii=1:numel(modeNames)
                    codeCovData=cvdg.getAll(modeNames{ii});
                    for jj=1:numel(codeCovData)
                        covData=codeCovData{jj}.codeCovData;
                        if isa(codeCovData{jj},'cvdata')
                            covData.refreshModelCovIds(codeCovData{jj});
                            covData.setFilterCtx(cvi.ReportUtils.getFilterCtxForReport(this.options,codeCovData{jj}));
                        else
                            this.forMLCodeCov=true;
                        end
                        allCodeCovGrp.add(covData,[covData.Name,' (',modeNames{ii},')']);
                    end
                end
            end

        end

        function allMetricNames=getCombinedEnabledMetricNames(~,allModels)
            allMetricNames=unique([allModels.enabledMetricNames,allModels.enabledTOMetricNames,allModels.metricNames,allModels.toMetricNames],'stable');
        end

        function[enabledMetricNames,enabledTOMetricNames]=getEnabledMetricNames(this)
            allCvd=[];
            for i=1:length(this.cvdatagroups)
                allCvd=[allCvd,this.cvdatagroups{i}.getAll()];%#ok<AGROW>
            end

            [enabledMetricNames,enabledTOMetricNames]=...
            cvi.ReportUtils.getMetricsForSummary(allCvd,...
            this.allModelsData.metricNames,this.allModelsData.toMetricNames,this.options);
        end
    end

end





