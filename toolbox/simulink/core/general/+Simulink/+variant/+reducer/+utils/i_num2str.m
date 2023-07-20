function str=i_num2str(str)










    if isa(str,'Simulink.Parameter')
        return;
    end

    if(isnumeric(str)||islogical(str))&&(~isenum(str))
        str=num2str(str);
    end
    if isenum(str)&&isscalar(str)

        str=[class(str),'.',char(str)];
    end


    if isa(str,'Simulink.data.Expression')
        str=char("slexpr('"+str.ExpressionString+"')");
        return;
    end
    if slvariants.internal.config.utils.isCompoundCtrlVarType(str)

        str=slvariants.internal.config.utils.getStrForCompoundType(str);
    else
        str=char(str);
    end
end
