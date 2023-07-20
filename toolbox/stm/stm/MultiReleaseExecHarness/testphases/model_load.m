


function TestResult=model_load(TestInfo,TestParams)


    TestResult=TestResultInit;

    try

        startTime=tic;


        TestResult.PrePostStats.pre_model_load_action=executeAndCollectPrePostActionStats(TestInfo.pre_simulink_load_action);


        TestResult.DesktopStatsBefore=StartDesktopStats;

        elapsedTime=toc(startTime);
        startTime=tic;


        if~isempty(TestInfo.simulink_load_action)
            evalin('base',TestInfo.simulink_load_action);
        else
            load_system(TestParams.ModelName);
        end

        elapsedTime=toc(startTime);


        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=elapsedTime;


        TestResult.PrePostStats.post_model_load_action=executeAndCollectPrePostActionStats(TestInfo.post_simulink_load_action);


        evalin('base',TestInfo.internal_post_simulink_load_action);


        if TestParams.ShowCompileStatistics


            set_param(TestParams.ModelName,'DisplayCompileStats','on');




        end

    catch

        elapsedTime=toc(startTime);
        TestResult.correctness=false;
        [TestResult.errormsg,TestResult.errormsgId]=lasterr;
        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=elapsedTime;
    end



