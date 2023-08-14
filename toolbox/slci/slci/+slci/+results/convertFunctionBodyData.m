
function convertFunctionBodyData(datamgr,verification_data,slciConfig)


    inputFuncBody=[];
    for k=1:numel(verification_data)
        cell_data=verification_data{k};
        switch(cell_data.name)
        case 'FUNC_DESC'
            inputFuncBody=cell_data.data;
        end
    end

    functionBodyReader=datamgr.getFunctionBodyReader();
    codeReader=datamgr.getCodeReader();

    if~isempty(inputFuncBody)

        mdl=slciConfig.getModelName();
        isTopMdl=slciConfig.getTopModel();


        funcMap=slci.internal.ReportUtil.categorize('ID',inputFuncBody);
        funcKeys=keys(funcMap);
        for k=1:numel(funcKeys)
            thisFuncKey=funcKeys{k};
            funcData=funcMap(thisFuncKey);

            if numel(funcData)>1
                DAStudio.error('Slci:results:DuplicateFuncDescData');
            end

            funcExists=functionBodyReader.hasObject(thisFuncKey);
            if funcExists

                funcObject=functionBodyReader.getObject(thisFuncKey);
            else
                funcType=slci.results.getFunctionType(...
                funcData.TYPE,funcData.NAME,mdl,isTopMdl);

                funcObject=slci.results.FunctionBodyObject(thisFuncKey,...
                funcData.NAME,...
                funcType);
            end


            if strcmp(funcData.EXPECTED_SLICES,'EMPTY')
                funcObject.setExpectedEmpty(true);
            else
                funcObject.setExpectedEmpty(false);
            end

            if strcmp(funcData.ISDEFINED,'TRUE')
                funcObject.setIsDefined(true);
            else
                assert(strcmp(funcData.ISDEFINED,'FALSE'));
                funcObject.setIsDefined(false);
            end


            [beginCodeKey,endCodeKey]=getCodeLocation(thisFuncKey,...
            funcData.START_POS,...
            funcData.END_POS,...
            codeReader);


            if(~strcmp(beginCodeKey,'FILE NOT FOUND:-1')&&...
                ~strcmp(endCodeKey,'FILE NOT FOUND:-1'))
                funcObject.setBodyStartCodeLocation(beginCodeKey);
                funcObject.setBodyEndCodeLocation(endCodeKey);
            end


            [beginCodeKey,endCodeKey]=getCodeLocation(thisFuncKey,...
            funcData.SIGNATURE_START_POS,...
            funcData.SIGNATURE_END_POS,...
            codeReader);


            if(~strcmp(beginCodeKey,'FILE NOT FOUND:-1')&&...
                ~strcmp(endCodeKey,'FILE NOT FOUND:-1'))
                funcObject.setSignatureStartCodeLoc(beginCodeKey);
                funcObject.setSignatureEndCodeLoc(endCodeKey);
            end


            if funcExists

                functionBodyReader.replaceObject(thisFuncKey,funcObject);
            else

                functionBodyReader.insertObject(thisFuncKey,funcObject);
            end

        end

    end

end



function[beginCodeKey,endCodeKey]=getCodeLocation(funcKey,...
    startPos,endPos,codeReader)


    [beginCodeKey,beginCodeFile,beginLineNum]=...
    slci.results.readEngineCodeKey(startPos);

    [endCodeKey,endCodeFile,endLineNum]=...
    slci.results.readEngineCodeKey(endPos);



    if(~strcmp(beginCodeKey,'FILE NOT FOUND:-1')&&...
        ~strcmp(endCodeKey,'FILE NOT FOUND:-1'))

        if~codeReader.hasObject(beginCodeKey)
            cObject=slci.results.CodeObject(beginCodeFile,...
            beginLineNum);
            cObject.addFunctionScope(funcKey);
            codeReader.insertObject(beginCodeKey,cObject);
        end

        if~codeReader.hasObject(endCodeKey)
            cObject=slci.results.CodeObject(endCodeFile,...
            endLineNum);
            cObject.addFunctionScope(funcKey);
            codeReader.insertObject(endCodeKey,cObject);
        end
    end
end
