function bResult=hasReqs(Obj,opt)
    if ischar(Obj)
        Obj=get_param(Obj,'Handle');
    end
    if~isnumeric(Obj)

        Obj=Advisor.Utils.Utils_hisl_0070.getHandleFromObject(Obj);
    end

    bResult=any(ismember(opt.slHs,Obj))||any(ismember(opt.sfHs,Obj));
end