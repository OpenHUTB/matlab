function[validated,TestParams]=IMT_HarnessValidateInputs(...
    ProjectName,...
    TestInfoObjectIndex,...
    TestSuites,...
    ProjectRoot,...
    varargin)

    validated=true;
    TestParams=struct;

    try


        TestParams=loc_HarnessInitTestParams();


        try
            if strcmpi(get(0,'Diary'),'on')
                diaryon=true;
            else
                diaryon=false;
            end
        catch
            diaryon=false;
        end

        if~diaryon
            if(exist(TestParams.diaryFileName,'file')==2)
                try
                    delete(TestParams.diaryFileName);
                catch
                    disp('Could Not delete diary file')
                    disp(lasterr)
                end
            end
            diary(TestParams.diaryFileName);
        end




        if isempty(ProjectName)
            validated=false;
            IMTDisplayMessage('No project specified. Cannot continue');
            return;
        end

        if~isnumeric(TestInfoObjectIndex)||TestInfoObjectIndex==0
            validated=false;
            IMTDisplayMessage(['Invalid Test Index, or Test Index missing. '...
            ,'Cannot continue']);
            return;
        end

        if isempty(TestSuites)||~iscell(TestSuites)
            validated=false;
            IMTDisplayMessage('No test suites specified. Cannot continue');
            return;
        end




        TestParams.ProjectName=ProjectName;
        TestParams.TestInfoObjectIndex=TestInfoObjectIndex;
        TestParams.TestSuites=TestSuites;
        TestParams.ProjectRoot=ProjectRoot;
        TestParams.MachineName='';







        if nargin<4
            return;
        end

        numOptionalArgs=nargin-4;

        if mod(numOptionalArgs,2)
            validated=false;
            IMTDisplayMessage('Mismatched parameter value pairs.');
            return;
        end

        for i=1:2:numOptionalArgs
            switch(lower(varargin{i}))
            case 'showcompilestatistics',TestParams.ShowCompileStatistics=varargin{i+1};
            case 'maximumsimulationtime',TestParams.MaximumSimulationTime=varargin{i+1};
            case 'timergranularity',TestParams.TimerGranularity=varargin{i+1};
            case 'logfilename',TestParams.LogFileName=varargin{i+1};
            case 'testbranch',TestParams.TestBranch=varargin{i+1};
            case 'postsimulinkstartupaction',TestParams.PostSimulinkStartupAction=varargin{i+1};
            case 'harnessdir',TestParams.HarnessDir=varargin{i+1};
            otherwise
                validated=false;
                IMTDisplayMessage(['Undefined parameter ',varargin{i},' specified.']);
            end
        end
        if isempty(TestParams.TestBranch)


            TestParams.TestBranch=strtok(TestParams.TestSuites{end},'X');
        end


        if~isfield(TestParams,'HarnessDir')
            TestParams.HarnessDir=fileparts(mfilename('fullpath'));
        end


    catch
        validated=false;
        IMTDisplayMessage(lasterr,'IMT Harness: Fatal error');
    end
end


function TestParams=loc_HarnessInitTestParams()
    TestParams.startdir=pwd;
    TestParams.ShowCompileStatistics=false;
    TestParams.MaximumSimulationTime=20*60;
    TestParams.TimerGranularity=1;



    TestParams.ModelName='';

    TestParams.TestBranch='';


    TestParams.LogFileName='';



    TestParams.diaryFileName=IMTGlobalSetting('diaryfilename');


end