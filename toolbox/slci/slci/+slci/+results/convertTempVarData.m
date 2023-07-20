
function[tempVarTable,codeTable]=convertTempVarData(datamgr,...
    verification_data,...
    tempVarTable,...
    codeTable)



    inputTempVarStatus=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'LOCAL_VAR'
            inputTempVarStatus=cell_data.data;
        end
    end


    tempVarReader=datamgr.getTempVarReader();
    codeReader=datamgr.getCodeReader();

    if~isempty(inputTempVarStatus)
        tempVarMap=slci.internal.ReportUtil.categorize('ID',inputTempVarStatus);
        tempVars=keys(tempVarMap);



        for k=1:numel(tempVars)

            tempVarKey=tempVars{k};
            tempVarInfo=tempVarMap(tempVarKey);
            tempVarName=tempVarInfo.NAME;

            tempVarFuncMap=slci.internal.ReportUtil.categorize('FUNC',tempVarInfo);
            tempVarPerFuncs=keys(tempVarFuncMap);
            datamgr.beginTransaction();
            try

                for p=1:numel(tempVarPerFuncs)
                    thisTempVarPerFunc=tempVarPerFuncs{p};
                    thisTempVarInfo=tempVarFuncMap(thisTempVarPerFunc);
                    hasObj=slci.results.cacheData('check',tempVarTable,tempVarReader,...
                    'hasObject',tempVarKey);



                    numTempVarInfo=numel(thisTempVarInfo);
                    cObjects=cell(numTempVarInfo,1);
                    status=thisTempVarInfo(1).STATUS;
                    for m=1:numTempVarInfo

                        [codeKey,codeFile,lineNum]=slci.results.readEngineCodeKey(...
                        thisTempVarInfo(m).CODE_ID);
                        if codeReader.hasObject(codeKey)

                            [cObject,codeTable]=...
                            slci.results.cacheData('get',codeTable,codeReader,...
                            'getObject',codeKey);
                        else

                            cObject=slci.results.CodeObject(codeFile,lineNum);
                            codeReader.insertObject(cObject.getKey(),cObject);
                        end


                        cObject.addFunctionScope(thisTempVarPerFunc);
                        cObject.addPrimVerSubstatus('LOCAL_DECLARATION');
                        cObject.addPrimTraceSubstatus('LOCAL_DECLARATION');

                        codeTable=...
                        slci.results.cacheData('update',codeTable,codeKey,cObject);

                        cObjects{m}=cObject;


                        if~strcmpi(status,thisTempVarInfo(m).STATUS)
                            DAStudio.error('Slci:results:ConflictingSubstatusTemp',tempVarKey);
                        end

                    end


                    if hasObj
                        [tObject,tempVarTable]=...
                        slci.results.cacheData('get',tempVarTable,tempVarReader,...
                        'getObject',tempVarKey);
                        tObject.addCodeObject(cObjects);
                    else

                        tObject=slci.results.TempVarObject(tempVarKey,...
                        tempVarName,...
                        thisTempVarPerFunc,...
                        cObjects);
                        tempVarReader.insertObject(tObject.getKey(),tObject);
                    end
                    tObject.setSubstatus(status);

                    tempVarTable=...
                    slci.results.cacheData('update',tempVarTable,tempVarKey,tObject);
                end

            catch ex

                datamgr.rollbackTransaction();
                throw(ex);

            end
            datamgr.commitTransaction();
        end


    end
end
