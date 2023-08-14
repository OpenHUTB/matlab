





function inBuiltPlotFunction(varInfo,floatVals,fixedVals)

    coder.internal.plotting.inBuiltPlotFunctionImpl(varInfo,floatVals,fixedVals,@computeError);


    function fxError=computeError(floatVarVal,fixedPtVarVal)



        fxError=double(floatVarVal)-double(fixedPtVarVal);
    end
end