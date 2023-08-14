classdef TestCaseResultsHolder<handle



    properties
        TestCaseID;
        TestFileID;
        TestCaseResultsID;
    end
    properties(SetAccess=immutable)
TestSuiteName
    end
    methods
        function obj=TestCaseResultsHolder(testSuiteName)
            obj.TestSuiteName=testSuiteName;
        end
        function tf=areIDsPopulated(obj)
            tf=~isempty(obj.TestCaseID)&&~isempty(obj.TestCaseResultsID);
        end
    end
end
