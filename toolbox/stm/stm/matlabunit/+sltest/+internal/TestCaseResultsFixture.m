classdef TestCaseResultsFixture<matlab.unittest.fixtures.Fixture



    properties(SetAccess=immutable)
        ResultSetHolder sltest.internal.ResultSetHolder;
        TestCaseResultsHolder sltest.internal.TestCaseResultsHolder;
    end
    methods
        function fixture=TestCaseResultsFixture(rsHolder,tcrHolder)
            fixture.ResultSetHolder=rsHolder;
            fixture.TestCaseResultsHolder=tcrHolder;
        end
        function setup(fixture)



            if~isempty(fixture.TestCaseResultsHolder)
                if~isempty(fixture.TestCaseResultsHolder.TestCaseID)&&...
                    ~isempty(fixture.TestCaseResultsHolder.TestFileID)&&...
                    ~isempty(fixture.ResultSetHolder.ResultSetID)
                    resultMatrix=sltest.internal.createResultMap(fixture.ResultSetHolder.ResultSetID);
                    fixture.TestCaseResultsHolder.TestCaseResultsID=stm.internal.initializeTestResult(...
                    fixture.TestCaseResultsHolder.TestCaseID,fixture.TestCaseResultsHolder.TestFileID,...
                    fixture.ResultSetHolder.ResultSetID,false,resultMatrix);
                    stm.internal.setTestCaseResult(fixture.TestCaseResultsHolder.TestCaseID,...
                    fixture.TestCaseResultsHolder.TestCaseResultsID,...
                    fixture.ResultSetHolder.ResultSetID,int32(-1));
                end
            end
        end

        function teardown(fixture)
            if~isempty(fixture.TestCaseResultsHolder)
                fixture.TestCaseResultsHolder.TestCaseID=[];
                fixture.TestCaseResultsHolder.TestCaseResultsID=[];
            end
        end

    end
    methods(Access=protected)
        function bool=isCompatible(~,~)
            bool=true;
        end
    end

end
