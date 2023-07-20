function load_model_before_code2model(model,varargin)



    if isempty(model)
        return;
    end

    hSrc=rtw.report.ReportInfo.getBrowserDocument();


    if nargin==4
        isTestHarness=true;
        harnessName=varargin{1};
        harnessOwner=varargin{2};
        modelFile=varargin{3};
    else
        isTestHarness=false;
        harnessName='';
        harnessOwner='';
        if~isempty(hSrc)
            modelFile=hSrc.ModelFileNameAtBuild;
        else
            modelFile='';
        end
    end

    if~isempty(hSrc)&&~rtw.report.ReportInfo.featureReportV2


        buildDir=hSrc.BuildDir;
    elseif isTestHarness&&rtw.report.ReportInfo.featureReportV2




        load_system(modelFile);
        Simulink.harness.load(harnessOwner,harnessName);
        rptInfo=rtw.report.getLatestReportInfo(harnessName);
        buildDir=rptInfo.BuildDirectory;
    else
        buildDir='';
    end

    if~isempty(modelFile)&&exist(modelFile,'file')&&...
        ~isempty(buildDir)&&exist(buildDir,'file')&&...
        rtw.report.ReportInfo.featureReportV2
        rtwprivate('rtwbindmodel',modelFile,buildDir,'rtw',...
        isTestHarness,harnessName,harnessOwner);
    elseif~isempty(modelFile)&&exist(modelFile,'file')&&...
        ~isempty(buildDir)&&exist(buildDir,'file')&&...
        ~rtw.report.ReportInfo.featureReportV2
        rtwprivate('rtwbindmodel',modelFile,hSrc.BuildDir,'rtw',...
        isTestHarness,harnessName,harnessOwner);
    end


    if isTestHarness

        if~isempty(modelFile)&&exist(modelFile,'file')
            load_system(modelFile);
        else
            mainModel=fileparts(modelFile);
            load_system(mainModel);
        end
        Simulink.harness.load(harnessOwner,harnessName);
    else
        load_system(model);
    end


