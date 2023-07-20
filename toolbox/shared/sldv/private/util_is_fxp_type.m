function[status,fxpTypeInfo,IsScaledDouble]=util_is_fxp_type(signalDataTypeStr,modelH)




    fxpTypeInfo=[];
    IsScaledDouble=false;


    if nargin<2||isempty(modelH)
        modelObj=[];
        baseDataTypeStr=signalDataTypeStr;
    else
        modelObj=get_param(bdroot(modelH),'Object');









        dataAccessor=[];

        [~,baseDataTypeStr]=util_is_sim_alias_type(signalDataTypeStr,dataAccessor,modelH);
    end

    if nargout>1
        getTypeInfo=true;
    else
        getTypeInfo=false;
    end

    parsedDt=SimulinkFixedPoint.DataTypeContainer.ParsedDataTypeContainer(baseDataTypeStr,modelObj);



    status=parsedDt.isFixed&&~origTypeNameIsMATLABBuiltinInt(parsedDt);

    if getTypeInfo
        fxpTypeInfo=parsedDt.ResolvedType;
        IsScaledDouble=parsedDt.isScaledDouble;
    end
end

function b=origTypeNameIsMATLABBuiltinInt(parsedDt)

    b=fixed.internal.type.isNameOfBuiltinInt(parsedDt.OriginalString);
end
