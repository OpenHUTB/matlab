classdef(Hidden)TestSuiteHolder<handle




    properties
        TestSuiteID;
    end
    properties(SetAccess=immutable)
        TestFileName;
        TestSuiteName;
    end
    methods
        function obj=TestSuiteHolder(testFileName,testSuiteName)
            obj.TestFileName=testFileName;
            obj.TestSuiteName=testSuiteName;
        end
    end

end
