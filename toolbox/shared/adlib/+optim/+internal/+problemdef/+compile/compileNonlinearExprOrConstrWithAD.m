function[compiledFun,compiledGrad,pkgDependencies,extraParams,subfun]=...
    compileNonlinearExprOrConstrWithAD(objects,compilefun,jointFunAndGrad,...
    numVars,idxNonlinObjects,idxVector,outName,gradName,...
    subfun,extraParams,extraParamsName,inMemory,generatedFileFolder,...
    isJacobianReqd,isObjectMax)




























    pkgDependencies=string.empty;
    numNonlinObjects=numel(idxNonlinObjects);
    compiledFun="";
    compiledGrad="";
    for nli=1:numNonlinObjects
        nlIdx=idxNonlinObjects(nli);

        reset=nli==numNonlinObjects;

        [nlfunstruct,jacStruct]=...
        compilefun(objects{nlIdx},'TotalVar',numVars,...
        'ExtraParams',extraParams,'ExtraParamsName',extraParamsName,...
        'Subfun',subfun,'InMemory',inMemory,...
        'InMemFolder',generatedFileFolder,'Reset',reset);

        extraParams=jacStruct.extraParams;
        subfun=nlfunstruct.subfun;

        if isempty(idxVector)




            objValName=outName;
            objGradName=gradName;
        else
            thisIdx=[idxVector.Start(nlIdx),idxVector.End(nlIdx)];


            thisIdx=unique(thisIdx);
            contiguous=true;
            idxStr=optim.internal.problemdef.indexing.getIndexingString(thisIdx,contiguous);
            objValName=outName+"("+idxStr+")";
            if isJacobianReqd
                objGradName=gradName+"("+idxStr+", :)";
            else
                objGradName=gradName+"(:,"+idxStr+")";
            end
        end


        [funBody,compiledFunVar]=optim.internal.problemdef.compile.compileNonlinearOutput(nlfunstruct,objValName);


        negateObj="";
        if isObjectMax(nlIdx)
            negateObj=objValName+" = -"+objValName+";"+newline;
        end


        compiledFun=compiledFun+funBody+negateObj;

        if isJacobianReqd

            jacStruct.funh="("+jacStruct.funh+")'";
        end



        compiledGrad=compiledGrad+optim.internal.problemdef.compile.compileNonlinearOutput(jacStruct,objGradName);

        if isObjectMax(nlIdx)
            compiledGrad=compiledGrad+objGradName+" = -"+objGradName+";"+newline;
        end


        if jointFunAndGrad


            compiledGrad=compiledGrad+compiledFunVar+newline+negateObj;
        end



        pkgDependencies=[pkgDependencies,nlfunstruct.pkgDepends,jacStruct.pkgDepends];%#ok<AGROW>
    end
