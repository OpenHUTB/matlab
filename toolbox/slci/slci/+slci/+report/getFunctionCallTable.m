



function[mTable,vTable,rTable]=getFunctionCallTable(datamgr)
    pFunctionCallReport=...
    slci.internal.Profiler('SLCI','FunctionCallVerification','','');


    functionCallReader=datamgr.getFunctionCallReader();
    functionCallObjects=...
    functionCallReader.getObjects(functionCallReader.getKeys());

    rObjects={};
    vObjects={};
    mObjects={};
    for k=1:numel(functionCallObjects)
        if strcmp(functionCallObjects{k}.getKind,'MATLAB_FUNCTION_CALL')
            mObjects{end+1}=functionCallObjects{k};%#ok
        else
            if strcmp(functionCallObjects{k}.getStatus(),'UNKNOWN')

                rObjects{end+1}=functionCallObjects{k};%#ok
            else

                vObjects{end+1}=functionCallObjects{k};%#ok
            end
        end
    end


    mSummaryData=getSummaryTable(datamgr,mObjects,false,true);
    vSummaryData=getSummaryTable(datamgr,vObjects,true,false);
    rSummaryData=getSummaryTable(datamgr,rObjects,false,false);


    mTable.SUMMARY.TABLEDATA=mSummaryData;
    mTable.DETAILS=[];
    mTable.STATUS=[];

    vTable.SUMMARY.TABLEDATA=vSummaryData;
    vTable.DETAILS=[];

    rTable.STATUS=[];
    rTable.SUMMARY.TABLEDATA=rSummaryData;
    rTable.DETAILS=[];

    pFunctionCallReport.stop();
end


function summaryTable=getSummaryTable(datamgr,functionCallObjects,hasStatus,isMatlabFunc)
    numObjects=numel(functionCallObjects);
    if numObjects>0
        if isMatlabFunc
            summaryTable(numObjects)=struct('OBJECTLIST',[],...
            'ATTRIBUTELIST',[],...
            'C_NAME',[],...
            'SOURCELIST',[]);
        else
            if hasStatus
                summaryTable(numObjects)=struct('OBJECTLIST',[],...
                'ATTRIBUTELIST',[],...
                'C_NAME',[],...
                'SOURCELIST',[],...
                'STATUS',[]);
            else
                summaryTable(numObjects)=struct('OBJECTLIST',[],...
                'ATTRIBUTELIST',[],...
                'C_NAME',[],...
                'SOURCELIST',[]);
            end
        end

        for k=1:numObjects
            funcObj=functionCallObjects{k};


            summaryTable(k).C_NAME.CONTENT=funcObj.getCName();


            if isMatlabFunc

                summaryTable(k).ATTRIBUTELIST=...
                formatAttributes(funcObj.getAttribute);
            else
                summaryTable(k).ATTRIBUTELIST=...
                formatAttributes(funcObj.getAttribute());
            end


            codeKeys=funcObj.getCodeKeys();
            numCodeObjects=numel(codeKeys);
            if numCodeObjects>0
                codeReader=datamgr.getCodeReader();
                codeObjects=codeReader.getObjects(codeKeys);
                summaryTable(k).SOURCELIST=...
                slci.report.formatSourceCodeObjects(codeObjects);
            else
                summaryTable(k).SOURCELIST.SOURCEOBJ.CONTENT='-';
            end


            blockKeys=funcObj.getBlockKeys();
            numBlockObjects=numel(blockKeys);
            if numBlockObjects>0
                blockReader=datamgr.getBlockReader();
                if~blockReader.hasObject(blockKeys{1})


                    obj_list(numel(blockKeys))=struct('SOURCEOBJ',[]);
                    for i=1:numel(blockKeys)
                        filelocation=strtok(blockKeys{i},':');
                        [~,filename]=fileparts(filelocation);
                        obj_list(i).SOURCEOBJ.CONTENT=...
                        slci.internal.ReportUtil.createFileLink(...
                        filelocation,filename);
                    end
                    summaryTable(k).OBJECTLIST=obj_list;
                else
                    blockObjects=blockReader.getObjects(blockKeys);
                    summaryTable(k).OBJECTLIST=...
                    slci.report.formatBlockObjects(blockObjects,datamgr);
                end
            else
                summaryTable(k).OBJECTLIST.SOURCEOBJ.CONTENT='-';
            end


            if hasStatus

                config=slci.internal.ReportConfig;
                summaryTable(k).STATUS.ATTRIBUTES=funcObj.getStatus;
                summaryTable(k).STATUS.CONTENT=...
                config.getStatusMessage(funcObj.getStatus);
            end
        end
    else
        summaryTable=[];
    end

end


function attributesList=formatAttributes(attribute)
    attrs=strsplit(attribute,';');

    listStr=attrs(~cellfun('isempty',attrs));

    listNum=numel(listStr);
    if listNum>0
        attributesList(listNum)=struct('SOURCEOBJ',[]);
        for i=1:listNum
            attributesList(i).SOURCEOBJ.CONTENT=listStr{i};
        end
    else
        attributesList.SOURCEOBJ.CONTENT='-';
    end
end

