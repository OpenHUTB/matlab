




function processFunctionBodyData(datamgr)

    profileFunctionBodyStage1=slci.internal.Profiler('SLCI',...
    'ProcessFunctionBodyResultsStage1',...
    '','');
    functionBodyReader=datamgr.getReader('FUNCTIONBODY');
    functionBodyKeys=functionBodyReader.getKeys();
    functionBodyObjects=functionBodyReader.getObjects(functionBodyKeys);
    numFunctions=numel(functionBodyObjects);

    profileFunctionBodyStage1.stop();


    profileFunctionBodyStage2=slci.internal.Profiler('SLCI',...
    'ProcessFunctionBodyResultsStage2',...
    '','');
    codeReader=datamgr.getReader('CODE');
    codeKeys=codeReader.getKeys();
    codeObjects=codeReader.getObjects(codeKeys);
    codeMap=getCodeObjectsPerFuncBody(codeObjects,datamgr);

    profileFunctionBodyStage2.stop()




    profileFunctionBodyStage3=slci.internal.Profiler('SLCI',...
    'ProcessFunctionBodyResultsStage3',...
    '','');
    codeSliceReader=datamgr.getReader('CODESLICE');
    codeSliceKeys=codeSliceReader.getKeys();
    sliceMap=groupKeys(codeSliceKeys,codeSliceReader);

    profileFunctionBodyStage3.stop();





    profileFunctionBodyStage4=slci.internal.Profiler('SLCI',...
    'ProcessFunctionBodyResultsStage4',...
    '','');
    tempVarReader=datamgr.getReader('TEMPVAR');
    tempVarKeys=tempVarReader.getKeys();
    tempVarMap=groupKeys(tempVarKeys,tempVarReader);

    profileFunctionBodyStage4.stop();

    profileFunctionBodyStage5=slci.internal.Profiler('SLCI',...
    'ProcessFunctionBodyResultsStage5',...
    '','');
    for k=1:numFunctions

        funcObject=functionBodyObjects{k};
        funcKey=funcObject.getKey();
        if isKey(sliceMap,funcKey)
            sliceKeys=sliceMap(funcKey);
            funcObject.addCodeSlices(sliceKeys);
        end

        if isKey(codeMap,funcKey)
            codeKeys=codeMap(funcKey);
            if~isempty(codeKeys)
                funcObject.addCodes(codeKeys);
            end
        end

        funcObject.computeCodeStatus(datamgr);


        funcObject=functionBodyObjects{k};
        funcKey=funcObject.getKey();
        if isKey(tempVarMap,funcKey)
            tempKeys=tempVarMap(funcKey);
            funcObject.addTempVarObjects(tempKeys);
        end


        funcObject.computeTempVarStatus(datamgr);


        functionBodyReader.replaceObject(funcKey,funcObject);
    end

    profileFunctionBodyStage5.stop();

end



function scopeMap=groupKeys(keyList,reader)
    scopeMap=containers.Map;
    objects=reader.getObjects(keyList);
    numObjects=numel(objects);
    for k=1:numObjects
        thisObj=objects{k};
        func=thisObj.getFunctionScope();
        if isKey(scopeMap,func)

            scopeMap(func)=[scopeMap(func),{thisObj.getKey()}];
        else
            scopeMap(func)={thisObj.getKey()};
        end
    end
end



function scopeMap=getCodeObjectsPerFuncBody(codeObjects,datamgr)

    functionBodyReader=datamgr.getReader('FUNCTIONBODY');
    functionBodyKeys=functionBodyReader.getKeys();
    numFunctions=numel(functionBodyKeys);
    if numFunctions==0
        scopeMap=containers.Map;
    else


        funcSignatureMap=prepareFuncSignatureMap(...
        functionBodyKeys,datamgr);


        scopeMap=containers.Map(functionBodyKeys,cell(1,numFunctions));
        numLocations=numel(codeObjects);
        for k=1:numLocations
            thisObj=codeObjects{k};
            if~strcmpi(thisObj.getStatus(),'NON_FUNCTIONAL')
                funcs=thisObj.getFunctionScope();
                for p=1:numel(funcs)
                    func=funcs{p};
                    if isKey(funcSignatureMap,func)...
                        &&~isFunctionSignature(thisObj,funcSignatureMap(func))
                        scopeMap(func)=[scopeMap(func),...
                        {thisObj.getKey()}];
                    end
                end
            end
        end
    end
end


function funcSignatureMap=prepareFuncSignatureMap(funcBodyKeys,datamgr)

    funcSignatureMap=containers.Map;

    numFunctions=numel(funcBodyKeys);
    assert(numFunctions>0);

    codeReader=datamgr.getReader('CODE');
    functionBodyReader=datamgr.getReader('FUNCTIONBODY');

    for idx=1:numFunctions
        funcBodyObj=functionBodyReader.getObject(funcBodyKeys{idx});
        signStartPos=funcBodyObj.getSignatureStartCodeLoc();
        signEndPos=funcBodyObj.getSignatureEndCodeLoc();
        if(~isempty(signStartPos)&&~isempty(signEndPos))
            startPosCode=codeReader.getObject(signStartPos);
            endPosCode=codeReader.getObject(signEndPos);
            funcSignatureMap(funcBodyKeys{idx})={startPosCode,...
            endPosCode};
        end
    end
end


function flag=isFunctionSignature(cObject,funcInfo)
    funcSignStartPos=funcInfo{1};
    funcSignEndPos=funcInfo{2};
    cLineNum=cObject.getLineNumber();
    if strcmp(cObject.getFileName(),funcSignStartPos.getFileName())&&...
        (funcSignStartPos.getLineNumber()<=cLineNum)&&...
        (funcSignEndPos.getLineNumber()>=cLineNum)
        flag=true;
    else
        flag=false;
    end
end
