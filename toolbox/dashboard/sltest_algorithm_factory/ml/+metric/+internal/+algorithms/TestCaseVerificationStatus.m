classdef TestCaseVerificationStatus<metric.SimpleMetric

    methods

        function obj=TestCaseVerificationStatus()
            obj.AlgorithmID='TestCaseVerificationStatus';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end


        function result=algorithm(this,resultFactory,artifacts)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;
            import sltest.testmanager.TestResultOutcomes;

            if length(artifacts)<=1
                val=TestCaseVerificationStatusEnum.NO_RESULT;
                result=resultFactory.createResult(this.ID,artifacts);
                result.Value=uint64(val);
                return;
            end

            resultArtifact=artifacts(2);
            testObj=sltest.testmanager.TestResult.getResultFromUUID(resultArtifact.Address);
            if~isempty(testObj)&&isequal(testObj.Outcome,'Disabled')
                val=TestCaseVerificationStatusEnum.NO_RESULT;

            elseif~isempty(testObj)
                val=TestCaseVerificationStatusEnum.UNVERIFIED;

                testObj=testObj(1);

                if strcmpi(testObj.TestCaseType,getString(message('stm:toolstrip:EquivalenceTest')))

                    val=TestCaseVerificationStatusEnum.VERIFIED;
                elseif strcmpi(testObj.TestCaseType,getString(message('stm:toolstrip:BaselineTest')))
                    val=this.analyzeEquivalenceTest(testObj);
                else
                    val=this.analyzeSimulationTest(testObj);
                end
            end

            result=resultFactory.createResult(this.ID,artifacts);
            result.Value=uint64(val);
        end
    end


    methods(Access=private)
        function val=analyzeSimulationTest(this,testObj)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;
            val=this.analyzeAssessments(testObj);

            if val==TestCaseVerificationStatusEnum.UNVERIFIED
                val=this.analyzeVerifyStatements(testObj);

                if val==TestCaseVerificationStatusEnum.UNVERIFIED
                    val=this.analyzeCustomCriteria(testObj);
                end
            end
        end


        function val=analyzeEquivalenceTest(this,testObj)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;
            val=TestCaseVerificationStatusEnum.UNVERIFIED;
            itrObj=testObj.getIterationResults;
            if~isempty(itrObj)
                itrsHaveBaseline=true;
                for k=1:length(itrObj)

                    itrsHaveBaseline=itrsHaveBaseline&&~isempty(itrObj(k).Baseline.BaselineFile);
                end
                if itrsHaveBaseline
                    val=TestCaseVerificationStatusEnum.VERIFIED;
                end
            elseif~isempty(testObj.Baseline.BaselineFile)
                val=TestCaseVerificationStatusEnum.VERIFIED;
            end

            if val==TestCaseVerificationStatusEnum.UNVERIFIED
                val=this.analyzeAssessments(testObj);

                if val==TestCaseVerificationStatusEnum.UNVERIFIED
                    val=this.analyzeVerifyStatements(testObj);

                    if val==TestCaseVerificationStatusEnum.UNVERIFIED
                        val=this.analyzeCustomCriteria(testObj);
                    end
                end
            end
        end


        function val=analyzeAssessments(~,testObj)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;

            val=TestCaseVerificationStatusEnum.UNVERIFIED;
            if~isempty(getAssessmentResults(testObj))
                results=getAssessmentResults(testObj);

                atleastOneIsTested=false;
                for i=1:numel(results)
                    resultStructs=results{i};
                    for j=1:numel(resultStructs)
                        if~strcmpi(resultStructs(j).Outcome,'Untested')
                            atleastOneIsTested=true;
                        end
                    end
                end

                if atleastOneIsTested
                    val=TestCaseVerificationStatusEnum.VERIFIED;
                    return
                end
            end
            iterations=testObj.getIterationResults;

            allItrsHaveAssessment=true;
            containsAssessment=false;
            for idx=1:numel(iterations)
                res=getAssessmentResults(iterations(idx));
                thisItrHasAssessment=false;
                if~isempty(res)

                    containsAssessment=true;
                    assessments=res{1};
                    for i=1:numel(assessments)
                        if~strcmpi(assessments(i).Outcome,'Untested')&&~strcmpi(assessments(i).Outcome,'Disabled')
                            thisItrHasAssessment=true;
                        end
                    end
                end
                allItrsHaveAssessment=allItrsHaveAssessment&&thisItrHasAssessment;
            end

            if containsAssessment&&allItrsHaveAssessment
                val=TestCaseVerificationStatusEnum.VERIFIED;
            end
        end


        function val=analyzeVerifyStatements(~,testObj)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;
            val=TestCaseVerificationStatusEnum.UNVERIFIED;
            s=stm.internal.getTestCaseResultDetail(testObj.getID);
            if~isempty(s.verifyResults)
                s.verifyResults.verifyRunOutcome=sltest.internal.Helper.cppOutcomeToMatlabOutcome(s.verifyResults.verifyRunOutcome);
                if~strcmpi(s.verifyResults.verifyRunOutcome,'Untested')
                    val=TestCaseVerificationStatusEnum.VERIFIED;
                end
            end
            iterations=testObj.getIterationResults;
            allItrsVerified=true;
            hasVerifyStatements=false;
            for idx=1:numel(iterations)
                s=stm.internal.getTestCaseResultDetail(iterations(idx).getID);
                if~isempty(s.verifyResults)
                    hasVerifyStatements=true;
                    s.verifyResults.verifyRunOutcome=sltest.internal.Helper.cppOutcomeToMatlabOutcome(s.verifyResults.verifyRunOutcome);

                    if strcmpi(s.verifyResults.verifyRunOutcome,'Untested')||strcmpi(s.verifyResults.verifyRunOutcome,'Disabled')
                        allItrsVerified=false;
                    end
                end
            end

            if hasVerifyStatements&&allItrsVerified
                val=TestCaseVerificationStatusEnum.VERIFIED;
            end
        end


        function val=analyzeCustomCriteria(~,testObj)
            import metric.internal.algorithms.TestCaseVerificationStatusEnum;
            val=TestCaseVerificationStatusEnum.UNVERIFIED;
            if~isempty(testObj.getCustomCriteriaResult)&&~strcmpi(testObj.getCustomCriteriaResult.Outcome,'Untested')...
                &&~strcmpi(testObj.getCustomCriteriaResult.Outcome,'Disabled')
                val=TestCaseVerificationStatusEnum.VERIFIED;
                return
            end

            allItrsHaveCustomCriteria=true;
            containsCustomCriteria=false;
            iterations=testObj.getIterationResults;

            for idx=1:numel(iterations)
                res=getCustomCriteriaResult(iterations(idx));
                thisItrHasCustomCriteria=false;
                if~isempty(res)
                    containsCustomCriteria=true;
                    if~strcmpi(res.Outcome,'Untested')&&~strcmpi(res.Outcome,'Disabled')
                        thisItrHasCustomCriteria=true;
                    end
                end
                allItrsHaveCustomCriteria=allItrsHaveCustomCriteria&&thisItrHasCustomCriteria;
            end

            if containsCustomCriteria&&allItrsHaveCustomCriteria
                val=TestCaseVerificationStatusEnum.VERIFIED;
            end
        end
    end
end
