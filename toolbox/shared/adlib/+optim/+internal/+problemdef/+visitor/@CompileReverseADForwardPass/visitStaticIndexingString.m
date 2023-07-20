function[indexingStr,indexingParens,indexDependsOnLoopVar]=visitStaticIndexingString(visitor,Op,addParens)









    NDIdx=numel(Op.Index)>1;

    if NDIdx



        addParens=2;
    end



    prevBody=visitor.ExprBody;
    visitor.ExprBody="";
    [indexingStr,indexingParens,indexIsArgOrVar,indexFixedVar,...
    indexDependsOnLoopVar]=compileStaticIndexingString(visitor,Op,addParens);
    indexBody=visitor.ExprBody;
    visitor.ExprBody=prevBody+indexBody;



    linIdxStr=indexingStr;
    linIdxParens=indexingParens;

    if NDIdx

        linIdxStr="arg"+visitor.getNumArgs();
        linIdxParens=0;


        contiguous=false;
        linIdxBody=linIdxStr+" = "+...
        "nd2linIdx("+optim.internal.problemdef.compile.getVectorString(Op.LhsSize,contiguous)...
        +", {"+indexingStr+"});"+newline;


        PackageLocation="optim.problemdef.gradients.indexing";
        visitor.PkgDepends(end+1)=PackageLocation;

        if~indexFixedVar



            addToExprBody(visitor,linIdxBody);
            indexBody="";
        else


            indexBody=indexBody+linIdxBody;
        end

    elseif~indexFixedVar&&~indexIsArgOrVar




        singleLine=true;
        addParens=Inf;
        [linIdxStr,linIdxParens,varBody]=addParensToArg(visitor,...
        linIdxStr,linIdxParens,indexIsArgOrVar,singleLine,addParens);
        indexBody="";
        addToExprBody(visitor,varBody);
    end


    storeForwardMemoryRAD(visitor,linIdxStr,indexFixedVar);
    isFixedVar=true;
    storeForwardMemoryRAD(visitor,linIdxParens,isFixedVar);
    storeForwardMemoryRAD(visitor,indexBody,isFixedVar);

end
