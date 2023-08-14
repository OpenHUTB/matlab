function names=getOutputNames(obj)










    expectedNameCount=getNumOutputs(obj);
    if expectedNameCount<0
        names="";
        return
    end

    fcnOutputCount=matlab.system.internal.numMethodOutputs(obj,'getOutputNamesImpl');
    nameFcn=@obj.getOutputNamesImpl;

    names=matlab.system.internal.getInputOrOutputNames(nameFcn,fcnOutputCount,expectedNameCount,'getOutputNamesInvalid');
end
