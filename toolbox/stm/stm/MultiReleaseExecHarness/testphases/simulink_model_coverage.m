



function TestResult=simulink_model_coverage(TestInfo,TestParams)


    TestResult=TestResultInit;

    try
        tstart=tic;

        evalin('base',TestInfo.pre_simulink_model_coverage_action);


        TestResult.DesktopStatsBefore=StartDesktopStats;





        if isfield(TestParams,'MaximumSimulationTime')&&~isinf(TestParams.MaximumSimulationTime)

            if~isempty(regexp(version,'R14','once'))

                warning('IMT:simulink_model_coverage:NoTimeout',...
                'Do not run simulink_model_coverage stage with R14SP3');
            else

                tstart=tic;
                evalin('base',sprintf('cvdo = cvsim(cvtest(''%s''),[0 %f]);',...
                TestParams.ModelName,TestParams.MaximumSimulationTime));
                elapsedTime=toc(tstart);
            end
        else
            tstart=tic;
            evalin('base',sprintf('cvdo = cvsim(''%s'');',TestParams.ModelName));
            elapsedTime=toc(tstart);
        end



        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=elapsedTime;


        evalin('base',TestInfo.post_simulink_model_coverage_action);

    catch %#ok<CTCH> backwards compatibility

        elapsedTime=toc(tstart);
        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=elapsedTime;
        err=lasterror;%#ok<LERR> backwards compatibility
        exprToCheck='Simulink:SL_SimTimeExceededTimeOut';
        if~isempty(strfind(err.identifier,exprToCheck))




            evalin('base',TestInfo.post_simulink_model_coverage_action);
        else
            TestResult.correctness=false;
            TestResult.error=err;
        end
    end

    if TestResult.correctness
        try
            cvdo=evalin('base','cvdo');

            settings=cvi.CvhtmlSettings;
            settings.showReport=0;
            cvhtml('coverage_report.html',cvdo,settings);
            if exist('coverage_report.html','file')
                htmlPath=fullfile(pwd,'coverage_report.html');
                imagesPath=fullfile(pwd,'scv_images');

                TestResult.SimulinkModelCoverageReport={htmlPath,imagesPath};
            end


            covpath=get_param(TestParams.ModelName,'CovPath');
            if covpath=='/'
                covpath=TestParams.ModelName;
            else
                covpath=[TestParams.ModelName,covpath];
            end;


            s=get_param(TestParams.ModelName,'CovMetricSettings');


            if(strfind(s,'d'))
                TestResult.decisioninfo=decisioninfo(cvdo,covpath);
                fprintf('Decisioninfo for %s: %i\n',covpath,TestResult.decisioninfo);
            end
            if(strfind(s,'c'))
                TestResult.conditioninfo=conditioninfo(cvdo,covpath);
                fprintf('Conditioninfo for %s: %i\n',covpath,TestResult.conditioninfo);
            end
            if(strfind(s,'m'))
                TestResult.mcdcinfo=mcdcinfo(cvdo,covpath);
                fprintf('MCDCinfo for %s: %i\n',covpath,TestResult.mcdcinfo);
            end
            if(strfind(s,'t'))
                TestResult.tableinfo=tableinfo(cvdo,covpath);
                fprintf('Tableinfo for %s: %i\n',covpath,TestResult.tableinfo);
            end

        catch %#ok<CTCH> backwards compatibility
            TestResult.correctness=false;
            TestResult.error=lasterror;%#ok<LERR> backwards compatibility
        end
    end


