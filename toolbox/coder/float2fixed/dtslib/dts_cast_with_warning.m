%#codegen




function out=dts_cast_with_warning(fcnOutput,kind,functionName,outputNum)
    coder.internal.prefer_const(fcnOutput,kind);
    coder.internal.allowHalfInputs;
    if nargin>=3
        coder.internal.prefer_const(functionName);
    end
    if nargin>=4
        coder.internal.prefer_const(outputNum);
    end

    coder.allowpcode('plain');
    coder.inline('always');


    float=isfloat(fcnOutput);

    FunctionKindUnknown=0;
    UserDefinedFunction=1;
    LibFunctionSkipped=2;
    LibFunctionNoWarnings=3;
    LibFunctionSimple=4;
    LibDoublePrecision=5;
    LibC89DoublePrecision=6;
    LibFunctionNotConverted=7;

    if kind~=LibFunctionNotConverted
        out=dts_cast(fcnOutput);
    else
        out=fcnOutput;
    end

    if float
        switch kind
        case LibDoublePrecision
            coder.internal.compileWarning(eml_message('Coder:FXPCONV:DTS_LibFcnDoublePrecision',functionName));
        case LibC89DoublePrecision
            coder.internal.compileWarning(eml_message('Coder:FXPCONV:DTS_LibFcnC89DoublePrecision',functionName));
        case LibFunctionNotConverted
            coder.internal.compileWarning(eml_message('Coder:FXPCONV:DTS_LibFcnNotConverted',functionName));
        end
    end

    switch kind
    case{LibFunctionNoWarnings,LibFunctionSkipped,UserDefinedFunction,LibFunctionNotConverted}

    otherwise
        if isa(fcnOutput,'double')&&~coder.internal.isConst(fcnOutput)
            if nargin==4
                coder.internal.compileWarning(eml_message('Coder:FXPCONV:DTS_LibFcnNthOutputDouble',outputNum,functionName));
            else

                coder.internal.compileWarning(eml_message('Coder:FXPCONV:DTS_LibFcnDoubleOutput',functionName));
            end
        end
    end
end


