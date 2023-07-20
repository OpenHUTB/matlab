function[TestResults]=MRTHarness(ProjectName,...
    TestInfoObjectIndex,...
    TestInfo,...
    ProjectRoot,...
    workerIndex,...
    varargin)










    TestResults=struct;
    TestSuites=TestInfo.SupportedTestSuites{1};


    if ischar(TestSuites)



        TestSuites=get_testsuites_mapping(TestSuites);
    end



    [validateFlag,TestParams]=IMT_HarnessValidateInputs(ProjectName,...
    TestInfoObjectIndex,...
    TestSuites,...
    ProjectRoot,...
    varargin{1:end});
    if~validateFlag
        return;
    end

    persistent hrnsPathAdded
    if isempty(hrnsPathAdded)
        hrnsRoot=fileparts(mfilename('fullpath'));
        addpath(fullfile(hrnsRoot,'testphases'));
        hrnsPathAdded=1;
    end


    try










        [modelPath,TestParams.ModelName,modelExt]=fileparts(TestInfo.ModelName);%#ok<ASGLU>


        for i=1:length(TestInfo.RelativePaths)
            addpath(fullfile(ProjectRoot,TestInfo.RelativePaths{i}));
        end


        for i=1:length(TestInfo.AbsolutePaths)
            addpath(TestInfo.AbsolutePaths{i});
        end




        for testSuiteIndex=1:numel(TestSuites)

            testPhase=TestSuites{testSuiteIndex};


            if strcmp(testPhase,'matlab_startup')
                eval(TestInfo.pre_matlab_startup_action);
                continue;
            end


            TestResult=feval(lower(testPhase),TestInfo,TestParams);

            TestResult.diaryFileName=TestParams.diaryFileName;
            TestResult.LogFileName=TestParams.LogFileName;



            if~TestResult.correctness
                errMsg=lasterr;
                IMTDisplayMessage(['# *********************** ',sprintf('\n')...
                ,' Test Phase "',testPhase,'" failed '...
                ,' With the following MATLAB error: ',sprintf('\n')...
                ,errMsg,sprintf('\n')...
                ,' Cannot continue ',sprintf('\n')...
                ,'# *********************** ',sprintf('\n')...
                ]);%#ok<*SPRINTFN>

                testFailure=true;
            else
                testFailure=false;
            end


            TestResults.(testPhase)=TestResult;

            if testFailure
                break;
            end

        end

        IMTCleanupTestEnv(TestInfo,TestParams);


    catch

        IMTDisplayMessage(lasterr,'Error caught: ');





        if~exist('TestResult','var')
            TestResult=TestResultInit;
        end





        [TestResult.errormsg,TestResult.errormsgId]=lasterr;
        TestResult.correctness=false;






        if exist('testSuiteIndex','var')
            testPhase=TestSuites{testSuiteIndex};
        else
            testPhase=TestSuites{1};
        end

        IMTCleanupTestEnv(TestInfo,TestParams);


        TestResults.(testPhase)=TestResult;


        rethrow(lasterror);
    end

    diary off;
end









