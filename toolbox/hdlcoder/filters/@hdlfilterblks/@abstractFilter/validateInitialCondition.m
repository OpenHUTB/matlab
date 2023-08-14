function v=validateInitialCondition(this,hC)






    v=hdlvalidatestruct;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if isSysObj
        sysObjHandle=hC.getSysObjImpl;
        if~all(sysObjHandle.InitialConditions==0)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:initCondNotSupported'));
        end
    else
        if~checkFilterBlkInitConds(this,hC)
            v(end+1)=hdlvalidatestruct(1,...
            message('hdlcoder:filters:validate:initCondNotSupported'));
        end
    end

