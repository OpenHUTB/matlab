function setFunctionAndRootInportBlockPeriod(aFunction,newSampleTime)





    inpBlock=swarch.utils.getFcnCallInport(aFunction);
    txn=mf.zero.getModel(aFunction).beginTransaction();
    if~isempty(inpBlock)

        set_param(inpBlock,'SampleTime',newSampleTime);
    else
        aFunction.period=newSampleTime;
    end


    if swarch.utils.isInlineSoftwareComponent(aFunction.calledFunctionParent)


        aFunction.calledFunction.period=newSampleTime;
    end
    txn.commit();
end
