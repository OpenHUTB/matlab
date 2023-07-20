


function TestResult=simulink_simulate(TestInfo,TestParams)



    TestResult=TestResultInit;

    try
        startTime=tic;

        evalin('base',TestInfo.pre_simulink_simulate_action);
        TestResult.STM.SimOut=evalin('base','simOut');


        try
            sltest_simout=TestResult.STM.SimOut.simOut;
        catch
            sltest_simout=[];
        end

        if(~TestInfo.STM_MRT)

            if isempty(TestInfo.simulink_simulate_action)


                if isfield(TestParams,'MaximumSimulationTime')&&~isinf(TestParams.MaximumSimulationTime)

                    evalin('base',sprintf('opts = simset(''TimeOut'', %f);',TestParams.MaximumSimulationTime));
                    TestResult.DesktopStatsBefore=StartDesktopStats;
                    elapsedTime=toc(startTime);
                    startTime=tic;
                    evalin('base',sprintf('simOut = sim(''%s'',[],opts);',TestParams.ModelName));
                    TestResult.STM.SimOut=evalin('base','simOut');
                else
                    TestResult.DesktopStatsBefore=StartDesktopStats;
                    elapsedTime=toc(startTime);
                    startTime=tic;
                    evalin('base',sprintf('simOut = sim(''%s'',[],[],[]);',TestParams.ModelName));
                    TestResult.STM.SimOut=evalin('base','simOut');
                end
            else

                TestResult.DesktopStatsBefore=StartDesktopStats;
                elapsedTime=toc(startTime);
                startTime=tic;
                evalin('base',TestInfo.simulink_simulate_action);
            end
        end

        elapsedTime=toc(startTime);

        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=elapsedTime;
        TestResult.DesktopStatsAfter.SimWallClockTime=elapsedTime;

        assignin('base','sltest_simout',sltest_simout);

        evalin('base',TestInfo.post_simulink_simulate_action);


    catch




        elapsedTime=toc(startTime);
        cachedError=lasterror;
        TestResult.DesktopStatsAfter=EndDesktopStats;
        TestResult.DesktopStatsAfter.elapsedTime=0;
        TestResult.DesktopStatsAfter.SimWallClockTime=elapsedTime;


        exprToCheck='Simulink:SL_SimTimeExceededTimeOut';
        if~isempty(strfind(cachedError.identifier,exprToCheck))




            disp('Simulation Timed out');
            lasterror('reset');
        else
            TestResult.correctness=false;
            [TestResult.errormsg,TestResult.errormsgId]=lasterr;
        end
    end

    if~TestParams.ShowCompileStatistics
        set_param(0,'DisplayCompileStats','off');
    end

