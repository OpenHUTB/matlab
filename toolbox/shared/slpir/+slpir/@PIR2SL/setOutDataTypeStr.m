function setOutDataTypeStr(this,slBlockName,sltype)
    if sltype.isEnumType
        set_param(slBlockName,'OutDataTypeStr',sltype.enumStr);
    elseif sltype.isnative

        set_param(slBlockName,'OutDataTypeStr',sltype.native);
    else

        set_param(slBlockName,'OutDataTypeStr',sltype.viadialog);
    end
end