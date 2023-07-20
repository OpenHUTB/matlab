function[compiledFun,extraParams,subfun]=compileNonlinearExprOrConstr(objects,...
    idxNonlinObjects,idxVector,outName,subfun,extraParams,...
    extraParamsName,inMemory,generatedFileFolder,isObjectMax)

































    compiledFun="";
    for nli=1:numel(idxNonlinObjects)
        nlIdx=idxNonlinObjects(nli);

        nlfunstruct=...
        compileNonlinearFunction(objects{nlIdx},...
        'ExtraParams',extraParams,'ExtraParamsName',extraParamsName,...
        'Subfun',subfun,'InMemory',inMemory,...
        'InMemFolder',generatedFileFolder);

        extraParams=nlfunstruct.extraParams;
        subfun=nlfunstruct.subfun;
        if isempty(idxVector)




            objValName=outName;
        else
            thisIdx=[idxVector.Start(nlIdx),idxVector.End(nlIdx)];


            thisIdx=unique(thisIdx);
            objValName=outName+"("+optim.internal.problemdef.indexing.getIndexingString(thisIdx,true)+")";
        end

        compiledFun=compiledFun+optim.internal.problemdef.compile.compileNonlinearOutput(nlfunstruct,objValName);

        if isObjectMax(nlIdx)
            compiledFun=compiledFun+objValName+" = -"+objValName+";"+newline;
        end
    end
