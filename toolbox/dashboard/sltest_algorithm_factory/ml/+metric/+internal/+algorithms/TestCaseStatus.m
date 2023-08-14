classdef TestCaseStatus<metric.SimpleMetric




    methods

        function obj=TestCaseStatus()
            obj.AlgorithmID='TestCaseStatus';
            obj.addSupportedValueDataType(metric.data.ValueType.Uint64);
            obj.Version=1;
        end

        function result=algorithm(this,resultFactory,artifacts)




            import metric.internal.algorithms.TestCaseStatusEnum;
            import sltest.testmanager.TestResultOutcomes;


            testArt=artifacts(1);
            refArts=testArt;

            if length(artifacts)<2
                val=TestCaseStatusEnum.UNTESTED;
            else

                resultArt=artifacts(2);
                refArts=[refArts;resultArt];

                testObj=sltest.testmanager.TestResult.getResultFromUUID(resultArt.Address);

                if~isempty(testObj)




                    testObj=testObj(1);




                    itrObj=testObj.getIterationResults;
                    if~isempty(itrObj)
                        outcomeArray=[];
                        for k=1:length(itrObj)



                            if alm.internal.sltest.visitor.TestResultHandler.isSimulationResult(itrObj(k))
                                outcomeArray=[outcomeArray,itrObj(k).Outcome];%#ok<AGROW>
                            end
                        end
                        outcomeArray=unique(outcomeArray);


                        if ismember(TestResultOutcomes.Disabled,outcomeArray)
                            val=TestCaseStatusEnum.DISABLED;
                        elseif ismember(TestResultOutcomes.Incomplete,outcomeArray)||...
                            ismember(TestResultOutcomes.Untested,outcomeArray)


                            val=TestCaseStatusEnum.UNTESTED;
                        elseif ismember(TestResultOutcomes.Failed,outcomeArray)


                            val=TestCaseStatusEnum.FAILED;
                        elseif ismember(TestResultOutcomes.Passed,outcomeArray)&&(length(outcomeArray)==1)



                            val=TestCaseStatusEnum.PASSED;
                        else
                            val=TestCaseStatusEnum.UNTESTED;
                        end

                    else
                        if testObj.Outcome==TestResultOutcomes.Failed
                            val=TestCaseStatusEnum.FAILED;
                        elseif testObj.Outcome==TestResultOutcomes.Passed
                            val=TestCaseStatusEnum.PASSED;
                        elseif testObj.Outcome==TestResultOutcomes.Disabled
                            val=TestCaseStatusEnum.DISABLED;
                        else

                            val=TestCaseStatusEnum.UNTESTED;
                        end
                    end
                else
                    val=TestCaseStatusEnum.UNTESTED;
                end
            end
            result=resultFactory.createResult(this.ID,refArts);
            result.Value=uint64(val);
        end
    end
end
