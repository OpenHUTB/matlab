function[out,outputFilePath]=generate(data,varargin)


























































    data=Sldv.ReportUtils.loadAndCheckSldvData(data);

    if nargin<2
        optArg=[];
    else
        optArg=varargin{1};
    end
    opts=parseOpts(optArg,data.AnalysisInformation);

    if nargin<3
        showUI=false;
    else
        showUI=varargin{2};
    end

    if nargin<4||isempty(varargin{3})
        repFilePath=[];
    else
        repFilePath=varargin{3};
    end

    if nargin<5||isempty(varargin{4})
        format='-fHTML';
    else
        format=varargin{4};
    end

    if nargin<6||isempty(varargin{5})||...
        strcmp(data.AnalysisInformation.Options.Mode,'PropertyProving')||...
        (Sldv.DataUtils.isXilSldvData(data)&&...
        ~strcmp(data.AnalysisInformation.Options.Mode,'TestGeneration'))
        filters=[];
    else
        filters=varargin{5};
    end



    if~isSLDVInstalledAndLicensed()
        error(message('Sldv:RunTestCase:SimulinkDesignVerifierNotLicensed'));
    end

    invalid=builtin('_license_checkout','Simulink_Design_Verifier','quiet');
    if invalid
        error(message('Sldv:RunTestCase:SimulinkDesignVerifierNotLicensed'));
    end

    if strcmp(format,'-fPDF')
        if~license('test','MATLAB_Report_Gen')
            out=false;%#ok<NASGU>
            outputFilePath='';%#ok<NASGU>
            error(message('Sldv:SldvReport:MissingRptGenLicense'));
        end
    end

    if~isempty(repFilePath)



        if(strcmp(format,'-fPDF'))


            [path,fileName,~]=fileparts(repFilePath);
            if isempty(path)
                repFilePath=fileName;
            else
                repFilePath=fullfile(path,fileName);
            end
            if(exist(repFilePath,'file')||exist([repFilePath,'.pdf'],'file'))
                error(message('Sldv:RptGen:FileExists'))
            end
        else
            if(exist(repFilePath,'file')||exist([repFilePath,'.html'],'file'))
                error(message('Sldv:RptGen:FileExists'))
            end
        end
        repPath=fileparts(repFilePath);
        if isempty(repPath)
            repPath=pwd;
            repFilePath=fullfile(repPath,repFilePath);
        else
            if(exist(repPath,'dir'))
                [~,attr]=fileattrib(repPath);
                if~(attr.UserWrite)
                    error(message('Sldv:RptGen:FileAttrib'))
                end
            end
        end
    end


    if strcmp(format,'-fHTML')
        createLink=1;
    else
        createLink=0;
    end

    out=true;


    progressBar=[];%#ok<NASGU> 
    if showUI
        progressBar=create_dvreport_progress();%#ok<NASGU> 
    end



    if~isempty(filters)
        if ischar(filters)
            [readStatus,filters,err]=sldvprivate('readFilterFiles',...
            data.ModelInformation.Name,...
            filters);
            if~readStatus
                error(err);
            end
        end
        filter=Sldv.Filter.mergeInMemory(filters);
    else
        filter=[];
    end

    justifiedInfo=sldvprivate('getObjectivesJustifiedAfterAnalysis',...
    data,...
    filter);


    data=Sldv.DataUtils.addInportUsage(data);

    sldvRep.sectionTitles=Sldv.ReportUtils.prepareSectionTitles(data);
    sldvRep.options=opts;

    if opts.summary
        sldvRep.summary=Sldv.ReportUtils.prepareSummary(data);
        sldvRep.analysisInfo=Sldv.ReportUtils.prepareAnalysisInfo(data,sldvRep.sectionTitles,createLink,filter);
    end

    if opts.objectives




        if isfield(data,'DeadLogic')
            [sldvRep.summary.objectives,sldvRep.DeadLogic]=Sldv.ReportUtils.prepareDeadLogic(opts,data,createLink,justifiedInfo);
            if(isempty(sldvRep.DeadLogic))






                sldvRep=rmfield(sldvRep,'DeadLogic');
            end
        end
        if~isfield(data,'DeadLogic')||slfeature('SLDVCombinedDLRTE')
            [sldvRep.objectives,sldvRep.summary.objectives]=...
            Sldv.ReportUtils.prepareObjectives(opts,data,sldvRep.sectionTitles,createLink,justifiedInfo);
        end
    end

    if opts.ranges
        sldvRep.ranges=Sldv.ReportUtils.prepareRanges(data,createLink);
    end

    if opts.objects
        sldvRep.modelObjects=Sldv.ReportUtils.prepareObjects(opts,data,createLink,justifiedInfo);
    end

    simData=Sldv.DataUtils.getSimData(data);
    if opts.testcases&&~isempty(simData)
        sldvRep.testCases=Sldv.ReportUtils.prepareTestCases(data,createLink,justifiedInfo);
    end

    if opts.properties



        if strcmp(data.AnalysisInformation.Options.ReportIncludeGraphics,'on')
            mdlsToClose=Sldv.ReportUtils.loadAllModels(data);
        else
            mdlsToClose={};
        end


        closeModelsOnCleanup=onCleanup(@()closeAllModels(mdlsToClose));

        [sldvRep.properties]=Sldv.ReportUtils.prepareProperties(data,createLink,justifiedInfo);
    end






    if isfield(data.ModelObjects,'modelScope')
        sldvRep.modelTypes=["designModel","observerModel"];
        sldvRep.sectionDescriptions=Sldv.ReportUtils.prepareSectionDescriptions(data,sldvRep);
    else
        sldvRep.modelTypes="designModel";
    end

    noView=strcmp(data.AnalysisInformation.Options.DisplayReport,'off');

    if isempty(repFilePath)
        outputFilePath=generateReportName(data);
    else
        outputFilePath=repFilePath;
    end

    savedWV=false;
    if evalin('base','exist(''sldvRep'')')
        tsldvRep=evalin('base','sldvRep');
        savedWV=true;
    end
    assignin('base','sldvRep',sldvRep);

    try
        outputFilePath=invokeRptgen('sldv_new.rpt',outputFilePath,noView,format);
    catch MEx
        evalin('base','clear sldvRep;');
        if savedWV
            assignin('base','sldvRep',tsldvRep);
        end
        error(message('Sldv:RptGen:GenErr'));
    end
    if(isempty(outputFilePath))
        out=false;
    end
    evalin('base','clear sldvRep;');
    if savedWV
        assignin('base','sldvRep',tsldvRep);
    end
end


function report=invokeRptgen(repFName,outFName,noView,format)

    opt=['-o',outFName];
    try
        if noView
            if strcmp(format,'-fHTML')
                reports=rptgen.report(repFName,'-quiet',opt,'-noview');
            else
                reports=rptgen.report(repFName,'-quiet',opt,'-noview',format);
            end
            report=reports{1};
        else
            report=generateReport(repFName,opt,format);
        end
    catch MEx
        if~strcmp(MEx.identifier,'Simulink:Commands:FindSystemInvalidPVPair')
            rethrow(MEx)
        end
    end
end

function reportFileName=generateReportName(data)
    modelName=data.ModelInformation.Name;
    opts=sldvoptions;
    reportFileName=Sldv.utils.settingsFilename(opts.ReportFileName,...
    opts.MakeOutputFilesUnique,'.html',modelName,false,true,opts);
    if isempty(reportFileName)
        reportFileName=fullfile(pwd,'sldv_report.html');
    end
end

function report=generateReport(repFName,opt,format)
    report='';
    try
        if strcmp(format,'-fHTML')
            reports=rptgen.report(repFName,'-quiet',opt);
        else
            reports=rptgen.report(repFName,'-quiet',opt,format);
        end
        report=reports{1};
    catch MEx
        checkEmptyReport(MEx);
    end
end

function checkEmptyReport(errorOFReportGen)
    if outOfMemoryError(errorOFReportGen)
        wstate=warning('backtrace');
        warning('backtrace','off');
        doclink='<a href="matlab:helpview(fullfile(docroot,''toolbox'',''sldv'',''sldv.map''), ''generate_report_large_models'')">Generating Report for Large Models</a>\n';
        warnmsg=getString(message('Sldv:RptGen:InsufficientMemory',doclink));
        warnmsg2=getString(message('Sldv:RptGen:NextSteps'));
        warnmsg=[warnmsg,'\n',warnmsg2];
        warning('Sldv:ReportUtils:generate:OutOfMemoryError',warnmsg);
        warning('backtrace',wstate.state);
    end
end

function out=outOfMemoryError(mexError)
    out=strcmp(mexError.identifier,'MATLAB:Java:GenericException')&&...
    (~isempty(strfind(mexError.message,'OutOfMemoryError'))||...
    ~isempty(strfind(mexError.message,lower('OutOfMemoryError'))));
end

function progressBar=create_dvreport_progress

    try
        progressBar=DAStudio.WaitBar;
        progressBar.setWindowTitle(getString(message('Sldv:RptGen:GeneratingSDVReport')));
        progressBar.setLabelText(DAStudio.message('Simulink:tools:MAPleaseWait'));
        progressBar.setCircularProgressBar(true);
        progressBar.show();
    catch Mex %#ok<NASGU>
        progressBar=[];
    end
end

function closeAllModels(mdlsToClose)
    if~isempty(mdlsToClose)
        cellfun(@(eachObsMdl)Sldv.close_system(eachObsMdl),mdlsToClose);
    end
end



function opts=parseOpts(optArg,info)
    opts.summary=false;
    opts.objectives=false;
    opts.objects=false;
    opts.testcases=false;
    opts.properties=false;
    opts.ranges=slavteng('feature','range')==1;
    opts.help=false;
    opts.usesldvoptions=false;
    opts.short=false;
    opts.includeGraphics=false;

    if isempty(optArg)
        opts=generateReportOptionsFromSldvOptions(info,opts);
    elseif iscell(optArg)
        for i=1:length(optArg)
            if(isfield(opts,optArg{i}))
                opts.(optArg{i})=true;
            else
                error(message('Sldv:RptGen:InvalidOpt'));
            end
        end
        if opts.usesldvoptions
            opts=generateReportOptionsFromSldvOptions(info,opts);
        end


        if(opts.testcases&&opts.properties)
            sldvOpts=generateReportOptionsFromSldvOptions(info,opts);
            opts.testcases=sldvOpts.testcases;
            opts.properties=sldvOpts.properties;

            if opts.testcases
                warning(message('Sldv:RptGen:DefaultOptToTestcases'));
            else
                warning(message('Sldv:RptGen:DefaultOptToProperties'));
            end

        end
    else
        opts.summary=true;
        if optArg>=2
            opts.objectives=true;
        end
        if optArg>=5
            opts.testcases=true;
        end
        if optArg>=8
            opts.objects=true;
        end

        if optArg>=10
            opts.help=true;
        end
    end

    opts=rmfield(opts,'usesldvoptions');

end

function opts=generateReportOptionsFromSldvOptions(info,opts)
    opts.summary=true;
    opts.help=true;

    if strcmp(info.Options.Mode,'TestGeneration')
        if strcmp(info.Options.getDerivedModelCoverageObjectives(),'None')
            opts.objects=false;
        else
            opts.objects=true;
        end
        if opts.short
            opts.testcases=false;
        else
            opts.testcases=true;
        end
        opts.objectives=true;
        opts.properties=false;
    else
        opts.objectives=true;
        opts.objects=false;
        if slfeature('SLDVCombinedDLRTE')&&strcmp(info.Options.Mode,'DesignErrorDetection')



            opts.testcases=false;
            if Sldv.utils.isRunTimeErrors(info.Options)
                opts.properties=true;
            else
                opts.properties=false;
            end


        elseif strcmp(info.Options.Mode,'DesignErrorDetection')&&strcmp(info.Options.DetectDeadLogic,'on')
            opts.testcases=true;
            opts.properties=false;
        else
            opts.testcases=false;
            opts.properties=true;
        end
        if strcmp(info.Options.ReportIncludeGraphics,'on')
            opts.includeGraphics=true;
        end
    end
end


