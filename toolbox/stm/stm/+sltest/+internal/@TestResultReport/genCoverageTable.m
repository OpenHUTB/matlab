function groupObj=genCoverageTable(reportObj,resultObj)















    p=inputParser;
    addRequired(p,'reportObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResultReport',...
    'sltest.internal.TestResultReport'},{'scalar'}));
    addRequired(p,'resultObj',...
    @(x)validateattributes(x,{'sltest.testmanager.TestResult'},{'scalar'}));
    p.parse(reportObj,resultObj);

    import mlreportgen.dom.*;
    import stm.internal.Coverage;
    groupObj=Group();

    if~reportObj.hasCoverageResults(resultObj)
        return;
    end


    [cvResults,topModels,coverageIDs]=resultObj.getCoverageResults();
    if(isempty(cvResults))
        return;
    end


    fieldNames={...
    getString(message('stm:CoverageStrings:Decision')),...
    getString(message('stm:CoverageStrings:Condition')),...
    getString(message('stm:CoverageStrings:MCDCLabel')),...
    getString(message('stm:CoverageStrings:FunctionLabel')),...
    getString(message('stm:CoverageStrings:FunctionCallLabel')),...
    getString(message('stm:CoverageStrings:LookupTableLabel')),...
    getString(message('stm:CoverageStrings:SldvAssumptionLabel')),...
    getString(message('stm:CoverageStrings:SldvConditionLabel')),...
    getString(message('stm:CoverageStrings:SldvProofLabel')),...
    getString(message('stm:CoverageStrings:SldvTestLabel')),...
    getString(message('stm:CoverageStrings:ExecutionLabel')),...
    getString(message('stm:CoverageStrings:RelationalBoundaryLabel')),...
    getString(message('stm:CoverageStrings:SaturationOnIntOverflowLabel'))
    };
    nFields=length(fieldNames);

    infoHandlers={...
    @decisioninfo,...
    @conditioninfo,...
    @mcdcinfo,...
    @executioninfo,...
    @executioninfo,...
    @tableinfo,...
    @getCoverageInfo,...
    @getCoverageInfo,...
    @getCoverageInfo,...
    @getCoverageInfo,...
    @executioninfo,...
    @relationalboundaryinfo,...
    @overflowsaturationinfo
    };
    assert(length(infoHandlers)==nFields);

    [outputPath,reportFileName,~]=fileparts(reportObj.outputFile);
    cvFolderName=reportFileName;
    outputCVFolder=fullfile(outputPath,cvFolderName);
    postFix=1;


    while(exist(outputCVFolder,'dir')>0)
        cvFolderName=[reportFileName,num2str(postFix)];
        outputCVFolder=fullfile(outputPath,cvFolderName);
        postFix=postFix+1;
    end
    mkdir(outputCVFolder);
    assert(exist(outputCVFolder,'dir')>0);

    total=0;
    nCVData=length(cvResults);
    cvSummary=cell(nCVData,nFields);
    cvMetricsToShow=zeros(1,nFields);
    cvComplexity=cell(nCVData,1);
    showComplexity=false;
    currentRelease=stm.internal.util.getReleaseInfo();
    onlyCurrent=true;
    isTopLevelModel=ones(nCVData,1,'logical');
    simModes=cell(1,nCVData);
    modelErrorInfo=struct('models',{cell(1,nCVData)},'count',0);

    modelNames=cell(nCVData,1);
    releaseNames=cell(nCVData,1);
    cvReportFiles=cell(nCVData,1);
    for dataIdx=1:nCVData
        cvdata=cvResults(dataIdx);
        cvFile=reportObj.saveCoverageToFile(cvdata);
        if isempty(cvFile)
            modelErrorInfo=handleCoverageReportError(modelErrorInfo,cvdata);
            continue;
        end

        [~,cvFileName,cvFileExt]=fileparts(cvFile);
        copyfile(cvFile,outputCVFolder);
        cvFile=fullfile(outputCVFolder,[cvFileName,cvFileExt]);
        if(ischar(cvFile))
            cvFile={cvFile};
        end
        total=total+1;


        try
            cvReportFile=reportObj.createCoverageReport(cvFile,topModels{dataIdx});
        catch
            modelErrorInfo=handleCoverageReportError(modelErrorInfo,cvdata);
            delete(cvFile{1});
            continue;
        end
        cvReportFile=cvReportFile{1};
        delete(cvFile{1});

        [~,cvReportName,cvReportExt]=fileparts(cvReportFile);
        cvReportFiles{total}=[cvReportName,cvReportExt];


        tmcr=stm.internal.getTestManagerCoverageResults(coverageIDs(dataIdx));


        modelNames{total}=tmcr.AnalyzedModel;


        releaseNames{total}=tmcr.Release;
        if onlyCurrent&&~strcmp(currentRelease,tmcr.Release)
            onlyCurrent=false;
        end


        simModes{total}=tmcr.SimMode;


        isTopLevelModel=getIsTopLevelModel(tmcr,isTopLevelModel,dataIdx);


        ownerModels=Coverage.getOwnerModel(cvdata.modelinfo);
        ownerModel=ownerModels{1};

        if Coverage.isModel(ownerModel)&&Coverage.isLibrary(ownerModel)
            oc=Coverage.restoreLibraryLock(ownerModel);%#ok<NASGU>
        end

        [slvnvAnalyzedModel,~]=Coverage.getSlvnvAnalyzedModel(cvdata,ownerModel,...
        tmcr.HarnessType,tmcr.HarnessOwner);


        [cvComplexity,showComplexity]=getComplexityInfo(cvdata,slvnvAnalyzedModel,...
        cvComplexity,showComplexity,dataIdx);


        [cvMetricsToShow,cvSummary]=getMetricCoverageInfo(cvdata,slvnvAnalyzedModel,...
        fieldNames,infoHandlers,cvMetricsToShow,cvSummary,total);
    end
    cvSummary(total+1:end,:)=[];

    colIndexToShow=(cvMetricsToShow>0);
    fieldsToShow=fieldNames(colIndexToShow);
    dataToShow=cvSummary(:,colIndexToShow);
    if showComplexity
        fieldsToShow=[{getString(message('stm:CoverageStrings:ComplexityLabel'))},fieldsToShow];
    end
    if(~isempty(fieldsToShow))
        nCVData=size(dataToShow,1);
        data=cell(nCVData,1);

        modelNameHeader=getString(message('stm:CoverageStrings:ModelName'));
        releaseHeader=getString(message('stm:CoverageStrings:ReleaseLabel'));
        simModeHeader=getString(message('stm:CoverageStrings:SimModeLabel'));
        if onlyCurrent
            headFields=[{modelNameHeader,simModeHeader},fieldsToShow];
        else
            headFields=[{modelNameHeader,releaseHeader,simModeHeader},fieldsToShow];
        end


        for dataIdx=1:nCVData
            if onlyCurrent
                tmp=[modelNames(dataIdx),isTopLevelModel(dataIdx),simModes{dataIdx}];
            else
                tmp=[modelNames(dataIdx),isTopLevelModel(dataIdx),releaseNames{dataIdx},simModes{dataIdx}];
            end

            if showComplexity
                tmp=[tmp,complexityToString(cvComplexity,dataIdx)];%#ok<AGROW>
            end
            data{dataIdx}=[tmp,metricOutcomesToString(dataToShow,dataIdx)];
        end


        append(groupObj,sltest.testmanager.ReportUtility.vspace(reportObj.SectionSpacing));


        text=Text(getString(message('stm:CoverageStrings:AggregatedCoverageResultsTitlePane')));
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.BodyFontName,...
        reportObj.BodyFontSize,reportObj.BodyFontColor,true,false);
        para=sltest.testmanager.ReportUtility.genParaDefaultStyle(text);
        para.OuterLeftMargin=reportObj.ChapterIndent;
        append(groupObj,para);


        nCols=length(headFields);
        table=FormalTable(nCols);
        table.TableEntriesStyle={OuterMargin('0mm')};
        table.OuterLeftMargin=reportObj.ChapterIndent;
        border='solid';
        color='Gray';
        width='1pt';
        table.Border=border;
        table.BorderWidth=width;
        table.BorderColor=color;
        table.RowSep=border;
        table.RowSepColor=color;
        table.RowSepWidth=width;
        table.ColSep=border;
        table.ColSepColor=color;
        table.ColSepWidth=width;

        onerow=TableRow();
        for c=1:length(headFields)
            text=Text(headFields{c});
            sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.TableFontName,...
            reportObj.TableFontSize,reportObj.TableFontColor,true,false);
            onerow.append(TableEntry(Paragraph(text)));
        end
        table.append(onerow);


        if(strcmp(reportObj.reportType,'html'))
            reportObj.addPartToHTMLReport(outputPath,cvFolderName);
        end
        for dataIdx=1:nCVData
            if~isempty(cvReportFiles{dataIdx})
                onerow=createCoverageTableRow(dataIdx,reportObj,data,cvReportFiles,cvFolderName);
                table.append(onerow);
            end
        end
        table.Style=[table.Style,{ResizeToFitContents(true)}];
        append(groupObj,table);
    end


    modelErrorInfo.models(modelErrorInfo.count+1:end)=[];
    if~isempty(modelErrorInfo.models)
        appendNotFoundSection(groupObj,modelErrorInfo);
    end
end

function onerow=createCoverageTableRow(dataIdx,reportObj,data,cvReportFiles,cvFolderName)
    import mlreportgen.dom.*;
    onerow=TableRow();


    isTopLevelModel=data{dataIdx}{2};
    if isTopLevelModel
        img=Image(reportObj.IconTopLevelModel);
    else
        img=Image(reportObj.IconModelReference);
    end
    sizeStr='16px';
    img.Width=sizeStr;
    img.Height=sizeStr;
    img.Style{end+1}=VerticalAlign('subscript');
    paragraph=Paragraph(img);
    paragraph.WhiteSpace='pre';
    paragraph.append(Text(' '));


    modelName=data{dataIdx}{1};
    cvReportFile=cvReportFiles{dataIdx};
    exlnkObj=ExternalLink(['./',cvFolderName,'/',cvReportFile],modelName);
    paragraph.append(exlnkObj);
    tableEntry=TableEntry(paragraph);
    onerow.append(tableEntry);


    simMode=data{dataIdx}{3};
    onerow=addSimMode(simMode,onerow,reportObj);


    for c=4:length(data{dataIdx})
        percent=data{dataIdx}{c};
        text=Text(percent);
        sltest.testmanager.ReportUtility.setTextStyle(text,reportObj.TableFontName,...
        reportObj.TableFontSize,reportObj.TableFontColor,false,false);
        paragraph=Paragraph(text);
        tableEntry=TableEntry(paragraph);
        tableEntry.VAlign='middle';
        onerow.append(tableEntry);
    end
end

function coverageMetricsCell=metricOutcomesToString(dataToShow,dataIdx)
    coverageMetricsCell=dataToShow(dataIdx,:);
    len=length(coverageMetricsCell);
    for i=1:len
        if isempty(coverageMetricsCell{i})

            coverageMetricsCell{i}=getString(message('stm:CoverageStrings:NotApplicableLabel'));
        else

            coverageMetricsCell{i}=sprintf('%d%%',coverageMetricsCell{i});
        end
    end
end

function complexityCell=complexityToString(cvComplexity,dataIdx)
    complexityCell=cvComplexity(dataIdx);
    if isempty(complexityCell{1})

        complexityCell{1}=0;
    end
end

function isTopLevelModel=getIsTopLevelModel(tmcr,isTopLevelModel,dataIdx)
    isTopLevelModel(dataIdx)=tmcr.IsTopLevelModel;
end

function[cvComplexity,showComplexity]=getComplexityInfo(cvdata,slvnvAnalyzedModel,...
    cvComplexity,showComplexity,dataIdx)
    cov=complexityinfo(cvdata,slvnvAnalyzedModel);
    if length(cov)==2
        cvComplexity{dataIdx}=cov(1);
        showComplexity=true;
    end
end

function[cvMetricsToShow,cvSummary]=getMetricCoverageInfo(cvdata,slvnvAnalyzedModel,...
    fieldNames,infoHandlers,cvMetricsToShow,cvSummary,total)
    for handleK=1:length(fieldNames)
        fieldName=fieldNames{handleK};
        if(strcmp(fieldName,getString(message('stm:CoverageStrings:SldvTestLabel'))))
            cov=getCoverageInfo(cvdata,slvnvAnalyzedModel,cvmetric.Sldv.test);
        elseif(strcmp(fieldName,getString(message('stm:CoverageStrings:SldvProofLabel'))))
            cov=getCoverageInfo(cvdata,slvnvAnalyzedModel,cvmetric.Sldv.proof);
        elseif(strcmp(fieldName,getString(message('stm:CoverageStrings:SldvConditionLabel'))))
            cov=getCoverageInfo(cvdata,slvnvAnalyzedModel,cvmetric.Sldv.condition);
        elseif(strcmp(fieldName,getString(message('stm:CoverageStrings:SldvAssumptionLabel'))))
            cov=getCoverageInfo(cvdata,slvnvAnalyzedModel,cvmetric.Sldv.assumption);
        elseif(strcmp(fieldName,getString(message('stm:CoverageStrings:FunctionLabel'))))
            [~,desc]=executioninfo(cvdata,slvnvAnalyzedModel);
            if isfield(desc,'function')&&~isempty(desc.function)
                covFcns=desc.function(~[desc.function.isFiltered]);
                covFcnsJustified=[covFcns.justifiedCoverage]>0;
                cov=[(sum([covFcns(~covFcnsJustified).executionCount]>0)+sum(covFcnsJustified)),numel(covFcns)];
            else
                cov=[];
            end
        elseif(strcmp(fieldName,getString(message('stm:CoverageStrings:FunctionCallLabel'))))
            [~,desc]=executioninfo(cvdata,slvnvAnalyzedModel);
            if isfield(desc,'functionCall')&&~isempty(desc.functionCall)
                covFcnCalls=desc.functionCall(~[desc.functionCall.isFiltered]);
                covFcnCallsJustified=[covFcnCalls.justifiedCoverage]>0;
                cov=[(sum([covFcnCalls(~covFcnCallsJustified).executionCount]>0)+sum(covFcnCallsJustified)),numel(covFcnCalls)];
            else
                cov=[];
            end
        else
            cov=infoHandlers{handleK}(cvdata,slvnvAnalyzedModel);
        end

        if length(cov)==2&&cov(2)~=0
            percent=round(100*cov(1)/cov(2));
            cvMetricsToShow(handleK)=1;
            cvSummary{total,handleK}=percent;
        end
    end
end

function docPart=appendNotFoundSection(docPart,notFound)
    import mlreportgen.dom.*;
    text=Text(getString(message('stm:ReportContent:CannotFindModelForCoverage')));
    docPart.append(text);
    ul=UnorderedList(notFound.models);
    ul.CustomAttributes={CustomAttribute('unordered-list-type','not-found')};
    docPart.append(ul);
end

function modelErrorInfo=handleCoverageReportError(modelErrorInfo,cvdata)
    modelErrorInfo.count=modelErrorInfo.count+1;
    modelErrorInfo.models{modelErrorInfo.count}=cvdata.modelinfo.analyzedModel;
end

function onerow=addSimMode(simMode,onerow,reportObj)
    import mlreportgen.dom.*;
    simMode=Text(simMode);
    sltest.testmanager.ReportUtility.setTextStyle(simMode,reportObj.TableFontName,...
    reportObj.TableFontSize,reportObj.TableFontColor,false,false);
    paragraph=Paragraph(simMode);
    onerow.append(TableEntry(paragraph));
end
