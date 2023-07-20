






function codeSummaryList=getCodeSummary(fnKeys,datamgr,reportConfig)


    numFunctions=numel(fnKeys);


    codeSummaryList(numFunctions)=...
    struct('FUNCTION',[],'STATUS',[],'COUNTLIST',[]);


    functionReader=datamgr.getReader('FUNCTIONINTERFACE');


    functionBodyReader=datamgr.getReader('FUNCTIONBODY');

    for k=1:numFunctions

        funcKey=fnKeys{k};
        funcInterfaceObject=functionReader.getObject(funcKey);


        if strcmp(funcInterfaceObject.getSubstatus('DEFINED'),...
            slci.internal.ReportConfig.getVerificationFailStatus())

            funcStatus=funcInterfaceObject.getStatus();
            message='Undefined Function';
            undefinedMsg.MESSAGE.CONTENT=message;
            codeSummaryList(k)=populateSummaryStructure(...
            funcInterfaceObject.getName(),funcStatus,undefinedMsg,reportConfig);
        else

            funcBodyObject=functionBodyReader.getObject(funcKey);
            if~funcBodyObject.hasCodes()
                funcStatus=funcBodyObject.getCodeStatus();
                message=reportConfig.getReasonMessage(...
                funcBodyObject.getCodeEmptyFunctionStatus());
                noCodeMessage.MESSAGE.CONTENT=message;
                codeSummaryList(k)=populateSummaryStructure(...
                funcInterfaceObject.getName(),funcStatus,noCodeMessage,...
                reportConfig);
            else

                codeKeys=funcBodyObject.getCodes;
                countMap=getCodeCounts(codeKeys,datamgr,reportConfig);
                countList=prepareCodeSummaryCounts(countMap,reportConfig);
                funcStatus=funcBodyObject.getCodeStatus();
                codeSummaryList(k)=populateSummaryStructure(...
                funcInterfaceObject.getName(),funcStatus,countList,...
                reportConfig);
            end
        end
    end
end





function structData=populateSummaryStructure(func,status,countList,...
    reportConfig)

    structData.FUNCTION.CONTENT=func;
    structData.FUNCTION.ATTRIBUTES=func;

    structData.STATUS.CONTENT=reportConfig.getStatusMessage(status);
    structData.STATUS.ATTRIBUTES=status;

    structData.COUNTLIST=countList;
end


function countMap=getCodeCounts(contribCodes,datamgr,reportConfig)


    codeReader=datamgr.getReader('CODE');
    codeObjects=codeReader.getObjects(contribCodes);





    statuses=reportConfig.getCodeVerStatusList();
    countMap=slci.internal.ReportUtil.getStatusCounts(codeObjects,...
    statuses);

end





function codeSummary=prepareCodeSummaryCounts(countMap,reportConfig)

    message='Lines of code with status ';
    statuses=reportConfig.getCodeVerStatusList();
    codeSummary=slci.report.formatSummaryCounts(countMap,...
    statuses,message,reportConfig);
end
