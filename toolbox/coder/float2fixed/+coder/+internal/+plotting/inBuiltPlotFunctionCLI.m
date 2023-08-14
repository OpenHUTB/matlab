





function inBuiltPlotFunctionCLI(varInfo,floatVals,fixedVals)


    coder.internal.plotting.inBuiltPlotFunctionImpl(varInfo,floatVals,fixedVals,@computeError);


    function fxError=computeError(floatVarVal,fixedPtVarVal)

        import coder.internal.plotting.PlotHelper;




        fxError=double(floatVarVal)-double(fixedPtVarVal);

        maxFxError=max(fxError(1:end));
        maxPosFxError=(maxFxError>0)*maxFxError;
        minFxError=min(fxError(1:end));
        maxNegFxError=(minFxError<0)*minFxError;
        if PlotHelper.safeAbs(maxPosFxError)>PlotHelper.safeAbs(maxNegFxError)
            topFxError=maxPosFxError;
        else
            topFxError=maxNegFxError;
        end


        maxAbsSigVal=max(PlotHelper.safeAbs(floatVarVal));
        maxPercentageFxError=0;
        if maxAbsSigVal>0
            maxPercentageFxError=(PlotHelper.safeAbs(topFxError)/maxAbsSigVal)*100;
        end

        disp(message('Coder:FxpConvDisp:FXPCONVDISP:posErr',num2str(double(maxPosFxError))).getString());
        disp(message('Coder:FxpConvDisp:FXPCONVDISP:negErr',num2str(double(maxNegFxError))).getString());
        disp(message('Coder:FxpConvDisp:FXPCONVDISP:absVal',num2str(double(maxAbsSigVal))).getString());
        disp(message('Coder:FxpConvDisp:FXPCONVDISP:percentageErr',num2str(double(maxPercentageFxError))).getString());
    end
end