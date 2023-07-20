classdef TestSuiteFixture<matlab.unittest.fixtures.Fixture



    properties(SetAccess=immutable)
        TestSuiteHolder sltest.internal.TestSuiteHolder;
    end
    methods
        function fixture=TestSuiteFixture(testSuiteHolder)
            fixture.TestSuiteHolder=testSuiteHolder;
        end

        function setup(fixture)

            if~isempty(fixture.TestSuiteHolder)
                if isempty(fixture.TestSuiteHolder.TestSuiteID)&&~isempty(fixture.TestSuiteHolder.TestSuiteName)
                    fixture.TestSuiteHolder.TestSuiteID=stm.internal.createScriptedTestSuite(fixture.TestSuiteHolder.TestFileName,fixture.TestSuiteHolder.TestSuiteName);
                end
            end
        end

        function teardown(fixture)
            if~isempty(fixture.TestSuiteHolder)
                fixture.TestSuiteHolder.TestSuiteID=[];
            end
        end

    end
    methods(Access=protected)
        function bool=isCompatible(~,~)
            bool=true;
        end
    end


end