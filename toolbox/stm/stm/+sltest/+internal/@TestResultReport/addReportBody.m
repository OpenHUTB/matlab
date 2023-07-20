function addReportBody(obj)












    import mlreportgen.dom.*;



    numOfResults=0;

    for ind=1:length(obj.ResultObjList)
        theNodeList=obj.ResultObjList{ind};
        numOfResults=numOfResults+length(theNodeList);
    end



    numResultsDone=0;


    docPart=Group();


    for ind=1:length(obj.ResultObjList)

        if(obj.ReportGenStatus>=2)
            break;
        end


        results=obj.ResultObjList{ind};
        for idx=1:length(results)

            if(obj.ReportGenStatus>=2)
                break;
            end

            result=results(idx);


            resultType=sltest.testmanager.ReportUtility.getTypeOfTestResult(result.Data);


            chapter=Group();


            resultContent='';

            if(resultType==sltest.testmanager.TestResultTypes.ResultSet)



                resultContent=obj.genResultSetBlock(result);
            elseif(resultType==sltest.testmanager.TestResultTypes.TestSuiteResult||...
                resultType==sltest.testmanager.TestResultTypes.TestFileResult)



                resultContent=obj.genTestSuiteResultBlock(result);
            elseif(resultType==sltest.testmanager.TestResultTypes.TestCaseResult||...
                resultType==sltest.testmanager.TestResultTypes.TestIterationResult)



                resultContent=obj.genTestCaseResultBlock(result);
            end


            if~isempty(resultContent)
                append(chapter,resultContent);
                if(isempty(obj.CustomTemplateFile))
                    append(chapter,obj.lineSeparator);
                end
            end

            append(docPart,chapter);


            numResultsDone=numResultsDone+1;
            percent=floor(numResultsDone*100/numOfResults);
            obj.ReportGenStatus=obj.getReportGenerationStatus();



            obj.updateReportGenerationStatus(percent);
        end
    end


    append(obj.BodyPart,docPart);
end
