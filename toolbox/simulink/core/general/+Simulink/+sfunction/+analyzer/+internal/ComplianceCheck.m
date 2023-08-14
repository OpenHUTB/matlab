classdef ComplianceCheck<handle



    properties(Abstract)
Description
Category
    end
    properties
input
output
    end
    properties(Constant)
        ENVIRONMENT_CHECK=1;
        SOURCE_CODE_CHECK=2;
        MEX_FILE_CHECK=3;
        ROBUSTNESS_CHECK=4;
        UNITTESTING_CHECK=5;
        NOTRUN=6;
        PASS=7;
        FAIL=8;
        WARNING=9;
        POLYSPACE_CHECK=10;
        NO_SOURCE_OR_COMPILER=11;
        messageIDs={'ComplianceCheckEnvironmentCheck','ComplianceCheckSourceCodeCheck',...
        'ComplianceCheckSfunMEXCheck','ComplianceCheckRobustnessCheck',...
        'ComplianceCheckUnitTestingCheck','ComplianceCheckNotRun',...
        'ComplianceCheckPass','ComplianceCheckFail',...
        'ComplianceCheckWarning','ComplianceCheckPolyspaceCodeProverCheck',...
        'ComplianceCheckNoSourceOrCompiler'};

    end
    methods
        function obj=ComplianceCheck(description,category)
            obj.Description=description;
            obj.Category=category;
        end
    end
    methods
        function output=run(obj,target)
            obj.input=constructInput(obj,target);
            [output.description,output.result,output.details]=obj.execute(obj.input);
            obj.output=output;
        end
    end

    methods(Abstract)
        [description,result,details]=execute(obj,input)
    end
    methods(Abstract)
        input=constructInput(obj,target)
    end
end

