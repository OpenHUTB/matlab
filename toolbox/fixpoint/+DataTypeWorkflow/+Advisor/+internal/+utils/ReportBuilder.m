classdef ReportBuilder<DataTypeWorkflow.Advisor.internal.utils.AbstractReportBuilder




    properties(Constant)
        PassStatus="Pass";
    end

    methods

        function buildCheckListStep(obj,ru)

            checkList=ru.getCheckList();


            obj.Report.CheckList=checkList;
        end

        function buildSummaryStep(obj,ru)

            summaryChecks={};


            checkList=ru.getCheckList();


            for idx=1:length(checkList)

                nameStr=checkList{idx}+"TableHeader";
                name=fxptui.message(nameStr);


                statusArr=ru.getUniqueStatusArr(checkList{idx});



                uiStatusArr=ru.convertToUIStatus(statusArr,checkList{idx});



                status=consolidateStatus(uiStatusArr);


                statusStr=string(status);


                summaryCheck=DataTypeWorkflow.Advisor.internal.utils.SummaryCheck(name,statusStr);


                summaryChecks{idx}=summaryCheck;
            end


            progressPercent=obj.computeProgressPercent(summaryChecks);


            obj.Report.SummaryChecks=summaryChecks;


            obj.Report.Progress=progressPercent;
        end

        function progressPercent=computeProgressPercent(obj,summaryChecks)
            passCount=0;
            checkCount=length(summaryChecks);
            for idx=1:checkCount

                if(strcmp(summaryChecks{idx}.Status,obj.PassStatus))
                    passCount=passCount+1;
                end
            end




            progressPercent=passCount*100/max(1,checkCount);
        end

        function buildDetailedStep(obj,ru)

            detailedChecks={};


            checkList=ru.getCheckList();


            for idx=1:length(checkList)

                name=checkList{idx};


                statusArr=ru.getUniqueStatusArr(name);


                [summary,headerArr,infoArr]=ru.getDetailedInfo(name,statusArr);



                detailedCheck=DataTypeWorkflow.Advisor.internal.utils.DetailedCheck(name,summary,headerArr,infoArr);


                detailedChecks{idx}=detailedCheck;%#ok<*AGROW>
            end


            obj.Report.DetailedChecks=detailedChecks;
        end
    end
end


