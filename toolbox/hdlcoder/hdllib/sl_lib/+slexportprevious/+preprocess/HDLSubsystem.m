function HDLSubsystem(obj)



    if isR2016aOrEarlier(obj.ver)
        placeholder='$bdroot';
        if hdlcoderui.isslhdlcinstalled
            repwith=hdlget_param(obj.modelName,'HDLSubsystem');
            torep=regexprep(repwith,['^',obj.modelName],placeholder);
        else
            repwith=obj.modelName;
            torep=placeholder;
        end
        obj.appendRule(['<slprops.hdlmdlprops<Array<WILDCARD|"',torep,'":repval "',repwith,'">>>']);
    end
end
