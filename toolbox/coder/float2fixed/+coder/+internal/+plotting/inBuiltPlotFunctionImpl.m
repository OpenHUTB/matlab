
function inBuiltPlotFunctionImpl(varInfo,floatVals,fixedVals,computeError)

    import coder.internal.plotting.PlotHelper;

    varName=varInfo.name;
    fcnName=varInfo.functionName;

    if iscell(floatVals)
        firstVal=floatVals{1};
    else
        firstVal=floatVals(1);
    end
    if ischar(firstVal)
        disp(message('Coder:FxpConvDisp:FXPCONVDISP:loggedValsCharType',varName).getString());
        disp(char(10));
        return;
    end

    if 2~=coder.internal.f2ffeature('MEXLOGGING')
        if iscell(floatVals)

            floatVals=coder.internal.ComparisonPlotService.cell2mat(floatVals);
            fixedVals=coder.internal.ComparisonPlotService.cell2mat(fixedVals);
        end
    end

    fxError=computeError(floatVals(1:end),fixedVals(1:end));


    escapedVarName=regexprep(varName,'_','\\_');
    escapedFcnName=regexprep(fcnName,'_','\\_');



    if~isreal(floatVals)
        flatFloatVals=PlotHelper.safeAbs(floatVals(1:end));
        floatTitle=[escapedFcnName,' > ','float : abs( ',escapedVarName,' )'];
    else
        flatFloatVals=floatVals(1:end);
        floatTitle=[escapedFcnName,' > ','float : ',escapedVarName];
    end

    if~isreal(fixedVals)
        flatFixedVals=PlotHelper.safeAbs(fixedVals(1:end));
        if varInfo.DoubleToSingle
            fixedTitle=[escapedFcnName,' > ','single : abs( ',escapedVarName,' )'];
        else
            fixedTitle=[escapedFcnName,' > ','fixed : abs( ',escapedVarName,' )'];
        end
    else
        flatFixedVals=fixedVals(1:end);
        if varInfo.DoubleToSingle
            fixedTitle=[escapedFcnName,' > ','single : ',escapedVarName];
        else
            fixedTitle=[escapedFcnName,' > ','fixed : ',escapedVarName];
        end
    end

    if~isreal(fxError)
        flatErrVals=PlotHelper.safeAbs(fxError);
    else
        flatErrVals=fxError;
    end


    f=figure;
    if varInfo.isOutput
        f.Name=sprintf('%s>output>%s: ',fcnName,varName);
    elseif varInfo.isInput
        f.Name=sprintf('%s>input>%s: ',fcnName,varName);
    else
        f.Name=sprintf('%s>expression>%s: ',fcnName,varName);
    end
    hold on;

    subplot(3,1,1);
    plot(flatFloatVals,'Color',coder.internal.LoggerService.FLOAT_PLOT_LINE_COLOR);
    title(floatTitle);

    subplot(3,1,2);
    plot(flatFixedVals,'Color',coder.internal.LoggerService.FIXED_PLOT_LINE_COLOR);
    title(fixedTitle);

    subplot(3,1,3);
    plot(flatErrVals,'Color',coder.internal.LoggerService.ERROR_PLOT_LINE_COLOR);
    title('error')

    hold off;
end