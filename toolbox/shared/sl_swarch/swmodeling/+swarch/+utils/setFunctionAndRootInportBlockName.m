function setFunctionAndRootInportBlockName(aFunction,newName)





    inpBlock=swarch.utils.getFcnCallInport(aFunction);
    txn=mf.zero.getModel(aFunction).beginTransaction();
    if~isempty(inpBlock)
        set_param(inpBlock,'Name',newName);
    else
        aFunction.setName(newName);
    end


    if swarch.utils.isInlineSoftwareComponent(aFunction.calledFunctionParent)



        aFunction.calledFunction.setName(newName);
        aFunction.calledFunctionName=newName;
    end
    txn.commit();
end
