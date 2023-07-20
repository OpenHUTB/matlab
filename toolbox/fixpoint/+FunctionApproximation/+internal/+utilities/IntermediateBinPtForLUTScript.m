classdef IntermediateBinPtForLUTScript<handle




    methods(Static)

        function intermediateNT=getIntermediateBinPtForLUTScript(nDims,outNT,tableNT)
































































            assert(outNT.isscalingbinarypoint);
            assert(tableNT.isscalingbinarypoint);




            intermediateNT=fixed.aggregateType(outNT,tableNT);



            subtractType1=FunctionApproximation.internal.utilities.IntermediateBinPtForLUTScript.fullPrecBinPtSubtractType(tableNT,tableNT);
            intermediateNT=fixed.aggregateType(intermediateNT,subtractType1);









            if nDims>1
                intermediateNT=fixed.internal.type.growPrecisionBits(intermediateNT,3);
            end

















        end

        function yNT=fullPrecBinPtSubtractType(aNT,bNT)


            bH=upperbound(bNT);
            aL=lowerbound(aNT);
            y=aL-bH;
            yNT=numerictype(y);









            yNT.SignednessBool=1;
        end

    end
end


