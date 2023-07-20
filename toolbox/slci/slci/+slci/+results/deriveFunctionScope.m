

function cObjects=deriveFunctionScope(cObjects,datamgr)



    numLocations=numel(cObjects);
    functionBodyReader=datamgr.getReader('FUNCTIONBODY');
    codeReader=datamgr.getReader('CODE');

    fBodyKeys=functionBodyReader.getKeys();
    fBodyObjects=functionBodyReader.getObjects(fBodyKeys);

    numFuncs=numel(fBodyObjects);




    fValidScopes=struct('KEY',{},'FILENAME',{},'STARTPOS',{},'ENDPOS',{});
    for k=1:numFuncs
        fObj=fBodyObjects{k};
        if isempty(fObj.getSignatureStartCodeLoc())||...
            isempty(fObj.getBodyEndCodeLocation())
            continue;
        else
            scope.KEY=fObj.getKey();
            startObj=codeReader.getObject(fObj.getSignatureStartCodeLoc());
            endObj=codeReader.getObject(fObj.getBodyEndCodeLocation());
            scope.FILENAME=startObj.getFileName();
            scope.STARTPOS=startObj.getLineNumber();
            scope.ENDPOS=endObj.getLineNumber();
            fValidScopes(end+1)=scope;%#ok
        end
    end



    for k=1:numLocations
        cObject=cObjects{k};
        codeFuncScopes=cObject.getFunctionScope();
        if isempty(codeFuncScopes)||all(cellfun(@isempty,codeFuncScopes))
            computeFunctionScope(cObject,fValidScopes);
        end
    end

end

function computeFunctionScope(cObject,fValidScopes)



    cLineNum=cObject.getLineNumber();
    cFileName=cObject.getFileName();
    for p=1:numel(fValidScopes)
        scope=fValidScopes(p);
        fileName=scope.FILENAME;
        startPos=scope.STARTPOS;
        endPos=scope.ENDPOS;



        if startPos<=cLineNum&&...
            endPos>=cLineNum&&...
            strcmp(fileName,cFileName)
            funcScope=scope.KEY;
            cObject.addFunctionScope(funcScope);
            return;
        end
    end
    cObject.addPrimVerSubstatus('OUT_OF_SCOPE');
    cObject.addPrimTraceSubstatus('OUT_OF_SCOPE');
end
