function outVal=iNum2Str(inVal,encloseNonDoubleNumericWithDataType)






    outVal=inVal;
    if isa(inVal,'double')
        outVal=num2str(inVal);
    elseif isa(inVal,'logical')

        outVal=char(string(inVal));
    elseif isa(inVal,'Simulink.data.Expression')
        outVal=strcat('=',inVal.ExpressionString);
    elseif isenum(inVal)
        outVal=[class(inVal),'.',char(inVal)];
    elseif isnumeric(inVal)
        if encloseNonDoubleNumericWithDataType
            outVal=[class(inVal),'(',num2str(inVal),')'];
        else
            outVal=num2str(inVal);
        end
    elseif slvariants.internal.config.utils.isCompoundCtrlVarType(inVal)



        outVal=slvariants.internal.config.utils.getStrForCompoundType(inVal);
    end
end
