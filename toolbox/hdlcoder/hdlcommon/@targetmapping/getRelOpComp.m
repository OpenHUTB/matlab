
function relopComp=getRelOpComp(hN,hSignalsIn,hSignalsOut,opName,sameDT,compName,desc,slHandle)


    newInputSignals=targetmapping.makeInputsUniformInDimension(hN,hSignalsIn,compName);

    relopComp=pircore.getRelOpComp(hN,newInputSignals,hSignalsOut,opName,sameDT,compName,desc,slHandle);
end

