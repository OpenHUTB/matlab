




function tempVarData=getTempVerification(fnKeys,datamgr,reportConfig)

    pTempVerReport=slci.internal.Profiler('SLCI','TempVarVerification','','');



    tempVarReader=datamgr.getReader('TEMPVAR');


    functionReader=datamgr.getReader('FUNCTIONINTERFACE');
    funcObjects=functionReader.getObjects(fnKeys);
    numFunctions=numel(funcObjects);


    functionBodyReader=datamgr.getReader('FUNCTIONBODY');


    resultsReader=datamgr.getReader('RESULTS');
    tempStatus=resultsReader.getObject('TempVarInspectionStatus');


    tempVarSummary(numFunctions)=struct('FUNCTION',[],'STATUS',[],'COUNTLIST',[]);
    tempVarDetail(numFunctions)=struct('SECTION',[],'TABLEDATA',[],'REASON',[]);

    verificationFailStatus=slci.internal.ReportConfig.getVerificationFailStatus();

    for k=1:numFunctions

        funcKey=fnKeys{k};
        funcInterfaceObject=funcObjects{k};

        if strcmp(funcInterfaceObject.getSubstatus('DEFINED'),...
            verificationFailStatus)


            hasTemp=false;
            message='Undefined Function';
            funcStatus=funcInterfaceObject.getStatus();
        else

            funcBodyObject=functionBodyReader.getObject(funcKey);
            funcStatus=funcBodyObject.getTempVarStatus();
            tempKeys=funcBodyObject.getTempVarObjects();
            if isempty(tempKeys)
                hasTemp=false;

                message=slci.report.getTempVarEmptyFunctionStatus(funcBodyObject);
            else
                hasTemp=true;
                tempObjects=tempVarReader.getObjects(tempKeys);
                statusMap=sortObjects(tempObjects);
            end
        end






        tempDetail=struct('SECTION',[],'TABLEDATA',[],'REASON',[]);
        tempDetail.SECTION.CONTENT=['Function : ',funcInterfaceObject.getName()];
        if hasTemp
            tempDetail.TABLEDATA=prepareTempVarDetail(...
            statusMap,datamgr,reportConfig);
            tempDetail.REASON=[];
        else

            tempDetail.TABLEDATA=[];
            tempDetail.REASON=message;
        end
        tempVarDetail(k)=tempDetail;





        tempSummary=struct('FUNCTION',[],'STATUS',[],'COUNTLIST',[]);


        tempSummary.FUNCTION.CONTENT=funcInterfaceObject.getName();


        tempSummary.STATUS.CONTENT=reportConfig.getStatusMessage(funcStatus);
        tempSummary.STATUS.ATTRIBUTES=funcStatus;


        if hasTemp
            tempSummary.COUNTLIST=prepareTempVarSummary(statusMap,reportConfig);
        else

            tempSummary.COUNTLIST.MESSAGE.CONTENT=message;
        end

        tempVarSummary(k)=tempSummary;

    end

    tempVarData.SUMMARY.STATUS.ATTRIBUTES=tempStatus;
    tempVarData.SUMMARY.STATUS.CONTENT=...
    reportConfig.getStatusMessage(tempStatus);
    tempVarData.SUMMARY.TABLEDATA=tempVarSummary;
    tempVarData.DETAIL.SECTIONLIST=tempVarDetail;

    pTempVerReport.stop();

end




function statusMap=sortObjects(tempObjects)

    numTemps=numel(tempObjects);
    statusMap=containers.Map;
    for k=1:numTemps
        thisStatus=tempObjects{k}.getStatus();
        if isKey(statusMap,thisStatus)
            existingObjects=statusMap(thisStatus);
            statusMap(thisStatus)=[existingObjects,tempObjects(k)];
        else
            statusMap(thisStatus)=tempObjects(k);
        end
    end

end





function tempSummary=prepareTempVarSummary(statusMap,reportConfig)

    statuses=reportConfig.getTempVerStatusList();
    numStatuses=numel(statuses);
    tempSummary(numStatuses)=struct('STATUS',[],'COUNT',[]);

    message='Temporary variables with status ';
    for p=1:numStatuses
        thisStatus=statuses{p};
        tempSummary(p).STATUS.CONTENT=[message...
        ,reportConfig.getStatusMessage(thisStatus),' : '];
        tempSummary(p).STATUS.ATTRIBUTES='UNKNOWN';


        if isKey(statusMap,thisStatus)
            numEl=numel(statusMap(thisStatus));
            tempSummary(p).COUNT.ATTRIBUTES=thisStatus;
        else
            numEl=0;
            tempSummary(p).COUNT.ATTRIBUTES='UNKNOWN';
        end
        tempSummary(p).COUNT.CONTENT=num2str(numEl);
    end
end


function detailTableData=...
    prepareTempVarDetail(statusMap,datamgr,reportConfig)

    tempObjects=values(statusMap);
    numAllTemps=numel(tempObjects);
    detailTableData(numAllTemps)=struct('SOURCEOBJ',[],'STATUS',[]);




    statuses=reportConfig.getTempVerStatusList();
    numStatuses=numel(statuses);
    m=1;
    for p=1:numStatuses
        status=statuses{p};


        if isKey(statusMap,status)
            tempObjects=statusMap(status);
            numTemps=numel(tempObjects);
            for k=1:numTemps
                detailTableData(m).SOURCEOBJ.CONTENT=...
                tempObjects{k}.getDispName(datamgr);
                detailTableData(m).STATUS.CONTENT=...
                reportConfig.getStatusMessage(status);
                detailTableData(m).STATUS.ATTRIBUTES=status;
                m=m+1;
            end
        end
    end
end

