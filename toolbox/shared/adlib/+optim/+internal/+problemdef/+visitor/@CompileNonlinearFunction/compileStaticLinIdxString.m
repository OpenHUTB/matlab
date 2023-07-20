function[indexingStr,indexingParens,linIdxBody]=compileStaticLinIdxString(visitor,Op,addParens)









    NDIdx=numel(Op.Index)>1;

    if NDIdx

        addParens=2;
    end



    [indexingStr,indexingParens]=compileStaticIndexingString(visitor,Op,addParens);


    linIdxBody="";
    if NDIdx

        idxArgName="arg"+visitor.getNumArgs();


        contiguous=false;
        linIdxBody=idxArgName+" = "+...
        "nd2linIdx("+optim.internal.problemdef.compile.getVectorString(Op.LhsSize,contiguous)...
        +", {"+indexingStr+"});"+newline;


        indexingStr=idxArgName;
        indexingParens=0;


        PackageLocation="optim.problemdef.gradients.indexing";
        visitor.PkgDepends(end+1)=PackageLocation;
    end

end
