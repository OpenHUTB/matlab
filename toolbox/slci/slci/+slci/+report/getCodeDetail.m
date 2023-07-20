






function codeDetailList=getCodeDetail(fnKeys,datamgr,reportConfig)


    numFunctions=numel(fnKeys);

    codeDetailList(numFunctions)=...
    struct('SECTION',[],'TABLEDATA',[],'REASON',[]);


    functionReader=datamgr.getReader('FUNCTIONINTERFACE');


    functionBodyReader=datamgr.getReader('FUNCTIONBODY');

    for k=1:numFunctions

        funcKey=fnKeys{k};


        funcInterfaceObject=functionReader.getObject(funcKey);
        notDefined=strcmp(funcInterfaceObject.getSubstatus('DEFINED'),...
        slci.internal.ReportConfig.getVerificationFailStatus());
        if notDefined

            heading=['Function : ',funcInterfaceObject.getName()];
            tableData=[];
            message='Undefined Function';
            codeDetailList(k)=populateDetailStructure(heading,tableData,message);
        else
            funcBodyObject=functionBodyReader.getObject(funcKey);
            if~funcBodyObject.hasCodes()

                heading=['Function : ',funcInterfaceObject.getName()];
                tableData=[];
                message=reportConfig.getReasonMessage(...
                funcBodyObject.getCodeEmptyFunctionStatus());
                codeDetailList(k)=populateDetailStructure(heading,tableData,message);
            else

                heading=['Function : ',funcInterfaceObject.getName()];


                codeSliceKeys=funcBodyObject.getCodeSlices;
                codeSliceReader=datamgr.getReader('CODESLICE');
                sliceObjects=codeSliceReader.getObjects(codeSliceKeys);
                tableData=prepareCodeDetail(sliceObjects,datamgr,reportConfig);
                message=[];
                codeDetailList(k)=populateDetailStructure(heading,tableData,message);
            end
        end
    end
end





function structData=populateDetailStructure(heading,tableData,message)
    structData.SECTION.CONTENT=heading;
    structData.TABLEDATA=tableData;
    structData.REASON=message;
end





function codeDetail=prepareCodeDetail(codeSlices,datamgr,reportConfig)

    codeReader=datamgr.getReader('CODE');

    numCodeSlices=numel(codeSlices);
    codeDetail(numCodeSlices)=struct('SLICELIST',[],'OBJECTLIST',[]);
    for k=1:numCodeSlices

        codeSliceObject=codeSlices{k};
        codeSliceName=codeSliceObject.getName();
        codeSliceKey=codeSliceObject.getKey();


        codeDetail(k).SLICELIST.SOURCEOBJ.CONTENT=...
        codeSliceObject.getDispName(datamgr);

        sliceStatus=codeSliceObject.getStatus();
        if isempty(strfind(codeSliceName,'NOT_AN_OUTPUT'))
            codeDetail(k).SLICELIST.STATUS.CONTENT=...
            reportConfig.getStatusMessage(sliceStatus);
            codeDetail(k).SLICELIST.STATUS.ATTRIBUTES=sliceStatus;
        else
            codeDetail(k).SLICELIST.STATUS.CONTENT='';
            codeDetail(k).SLICELIST.STATUS.ATTRIBUTES=sliceStatus;
        end


        codeKeys=codeSliceObject.getContributingSources();
        codeObjects=codeReader.getObjects(codeKeys);
        numCodeObjects=numel(codeKeys);
        lineNum=ones(numCodeObjects,1);
        for p=1:numCodeObjects

            codeObject=codeObjects{p};

            codeDetail(k).OBJECTLIST(p).SOURCEOBJ.CONTENT=...
            codeObject.getDispName(datamgr);

            cstatus=codeObject.getStatusForSlice(codeSliceKey);
            codeDetail(k).OBJECTLIST(p).STATUS.CONTENT=...
            reportConfig.getStatusMessage(cstatus);
            codeDetail(k).OBJECTLIST(p).STATUS.ATTRIBUTES=cstatus;


            csubstatus=codeObject.getSubstatusForSlice(codeSliceKey);
            if~strcmp(cstatus,'VERIFIED')&&~isempty(csubstatus)
                substatusReason=reportConfig.getReasonMessage(csubstatus);
                if~isempty(substatusReason)
                    codeDetail(k).OBJECTLIST(p).MESSAGE.CONTENT=...
                    [' (',substatusReason,') '];
                end
            end

            lineNum(p)=codeObject.getLineNumber();
        end


        [~,sortedIdxs]=sort(lineNum);
        codeDetail(k).OBJECTLIST=codeDetail(k).OBJECTLIST(sortedIdxs);
    end
end
