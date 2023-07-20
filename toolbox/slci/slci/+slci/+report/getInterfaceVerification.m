





function interfaceData=getInterfaceVerification(functionKeys,datamgr,reportConfig)

    pInterfaceVerReport=slci.internal.Profiler('SLCI','InterfaceVerification','','');



    numFunctions=numel(functionKeys);
    functionReader=datamgr.getReader('FUNCTIONINTERFACE');
    functionObjects=functionReader.getObjects(functionReader.getKeys());


    resultsReader=datamgr.getReader('RESULTS');
    status=resultsReader.getObject('InterfaceInspectionStatus');








    functionList(numFunctions)=struct('FUNCTION',[],'STATUS',[],'DETAIL',[]);
    for k=1:numFunctions

        funcObject=functionObjects{k};
        functionList(k).FUNCTION.CONTENT=funcObject.getName();

        thisStatus=funcObject.getStatus;
        functionList(k).STATUS.ATTRIBUTES=thisStatus;
        functionList(k).STATUS.CONTENT=...
        reportConfig.getStatusMessage(thisStatus);




        functionList(k).DETAIL.CONTENT=getReason(funcObject,reportConfig);
    end

    interfaceSummary.STATUS.ATTRIBUTES=status;
    interfaceSummary.STATUS.CONTENT=...
    reportConfig.getStatusMessage(interfaceSummary.STATUS.ATTRIBUTES);
    interfaceSummary.TABLEDATA=functionList;







    detailList(numel(functionObjects))=struct;
    for k=1:numel(functionObjects)
        detailList(k).SECTION.CONTENT=['Function : '...
        ,functionObjects{k}.getName()];
        detailList(k).TABLEDATA=formatInterfaceDetail(...
        functionObjects{k},reportConfig);
    end
    interfaceDetail.SECTIONLIST=detailList;


    interfaceData.SUMMARY=interfaceSummary;
    interfaceData.DETAIL=interfaceDetail;

    pInterfaceVerReport.stop();

end



function interfaceDetail=formatInterfaceDetail(funcObject,reportConfig)


    interfaceDetail(1).MESSAGE.CONTENT='Number of function arguments ';
    numargStatus=funcObject.getSubstatus('NUMARG');
    interfaceDetail(1).STATUS.CONTENT=...
    reportConfig.getStatusMessage(numargStatus);
    interfaceDetail(1).STATUS.ATTRIBUTES=numargStatus;

    interfaceDetail(2).MESSAGE.CONTENT='Function argument names ';
    argnameStatus=funcObject.getSubstatus('ARGNAME');
    interfaceDetail(2).STATUS.CONTENT=...
    reportConfig.getStatusMessage(argnameStatus);
    interfaceDetail(2).STATUS.ATTRIBUTES=argnameStatus;

    interfaceDetail(3).MESSAGE.CONTENT='Function argument data types ';
    datatypeStatus=funcObject.getSubstatus('ARGTYPE');
    interfaceDetail(3).STATUS.CONTENT=...
    reportConfig.getStatusMessage(datatypeStatus);
    interfaceDetail(3).STATUS.ATTRIBUTES=datatypeStatus;

    interfaceDetail(4).MESSAGE.CONTENT='Function return type ';
    returnTypeStatus=funcObject.getSubstatus('RETURNTYPE');
    interfaceDetail(4).STATUS.CONTENT=...
    reportConfig.getStatusMessage(returnTypeStatus);
    interfaceDetail(4).STATUS.ATTRIBUTES=returnTypeStatus;

end

function reason=getReason(funcObject,reportConfig)

    if~strcmp(funcObject.getSubstatus('DEFINED'),'VERIFIED')
        reason='UNDEFINED';
    elseif(~strcmp(funcObject.getSubstatus('NUMARG'),'VERIFIED')||...
        ~strcmp(funcObject.getSubstatus('ARGTYPE'),'VERIFIED')||...
        ~strcmp(funcObject.getSubstatus('ARGNAME'),'VERIFIED')||...
        ~strcmp(funcObject.getSubstatus('RETURNTYPE'),'VERIFIED'))
        reason='SIGNATURE_ERROR';
    else
        reason='PASSED';
    end
    reason=reportConfig.getInterfaceMessage(reason);
end
