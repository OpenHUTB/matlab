function functionInterfaceTable=convertFunctionData(datamgr,...
    verification_data,functionInterfaceTable,slciConfig)





    inputFuncStatus=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'INTERFACE_VERIFICATION_STATUS'
            inputFuncStatus=cell_data.data;
        end
    end



    functionInterfaceReader=datamgr.getFunctionInterfaceReader;

    if~isempty(inputFuncStatus)

        mdl=slciConfig.getModelName();
        isTopMdl=slciConfig.getTopModel();

        funcMap=slci.internal.ReportUtil.categorize('ID',inputFuncStatus);
        funcKeys=keys(funcMap);
        datamgr.beginTransaction();
        try
            for k=1:numel(funcKeys)

                funcKey=funcKeys{k};
                funcInfo=funcMap(funcKey);

                hasObj=slci.results.cacheData('check',functionInterfaceTable,...
                functionInterfaceReader,'hasObject',funcKey);
                if hasObj
                    [fObject,functionInterfaceTable]=...
                    slci.results.cacheData('get',functionInterfaceTable,...
                    functionInterfaceReader,'getObject',funcKey);
                else
                    funcType=slci.results.getFunctionType(...
                    funcInfo(1).TYPE,funcInfo(1).NAME,mdl,isTopMdl);



                    switch(funcType)
                    case 'graphical'
                        fObject=slci.results.StateflowInterfaceObject(funcKey,...
                        funcInfo(1).NAME,funcInfo(1).SYSTEM,funcType);
                    otherwise
                        fObject=slci.results.SubSystemInterfaceObject(funcKey,...
                        funcInfo(1).NAME,funcInfo(1).SYSTEM,funcType);
                    end

                    functionInterfaceReader.insertObject(funcKey,fObject);
                end

                funcInfo=funcMap(funcKey);
                reasons=cell(1,numel(funcInfo));
                for p=1:numel(funcInfo)




                    reasons{k}=funcInfo(p).REASON;
                end

                setReason(fObject,reasons);
                functionInterfaceTable=slci.results.cacheData('update',...
                functionInterfaceTable,funcKey,fObject);
            end
            datamgr.commitTransaction();
        catch ex
            datamgr.rollbackTransaction();
            throw(ex);
        end
    end
end

function setReason(fObject,reasons)

    failStatus=slci.internal.ReportConfig.getVerificationFailStatus();
    passStatus=slci.internal.ReportConfig.getVerificationPassStatus();

    if any(strcmp(reasons,'UNDEFINED'))
        fObject.setSubstatus('DEFINED',failStatus);

        fObject.setSubstatus('NUMARG','NOT_PROCESSED');
        fObject.setSubstatus('ARGTYPE','NOT_PROCESSED');
        fObject.setSubstatus('ARGNAME','NOT_PROCESSED');
        fObject.setSubstatus('RETURNTYPE','NOT_PROCESSED');
        return;
    else
        fObject.setSubstatus('DEFINED',passStatus);
    end

    if any(strcmp(reasons,'NUMARG_MISMATCH'))
        fObject.setSubstatus('NUMARG',failStatus);


        fObject.setSubstatus('ARGTYPE','NOT_PROCESSED');
        fObject.setSubstatus('ARGNAME','NOT_PROCESSED');
        fObject.setSubstatus('RETURNTYPE','NOT_PROCESSED');
        return;
    else
        fObject.setSubstatus('NUMARG',passStatus);
    end


    if any(strcmp(reasons,'ARGTYPE_MISMATCH'))
        fObject.setSubstatus('ARGTYPE',failStatus);
    else
        fObject.setSubstatus('ARGTYPE',passStatus);
    end

    if any(strcmp(reasons,'ARGNAME_MISMATCH'))
        fObject.setSubstatus('ARGNAME',failStatus);
    else
        fObject.setSubstatus('ARGNAME',passStatus);
    end

    if any(strcmp(reasons,'RETURNTYPE_MISMATCH'))
        fObject.setSubstatus('RETURNTYPE',failStatus);
    else
        fObject.setSubstatus('RETURNTYPE',passStatus);
    end

end
