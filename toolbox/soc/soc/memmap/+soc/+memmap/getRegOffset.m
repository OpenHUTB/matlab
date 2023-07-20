function regAddr=getRegOffset(obj,compname,regname)
    ip=findobj(obj.map,'name',compname);
    reg=findobj(ip.regs,'register',regname);
    regAddr=reg.offset;
end
