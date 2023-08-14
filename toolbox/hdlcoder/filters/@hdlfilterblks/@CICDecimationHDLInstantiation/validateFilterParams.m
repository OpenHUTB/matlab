function v=validateFilterParams(this,hC)


    v=hdlvalidatestruct;

    isSysObj=isa(hC,'hdlcoder.sysobj_comp');
    if~isSysObj
        bfp=hC.SimulinkHandle;
        block=get_param(bfp,'Object');
        switch block.ftype
        case 'Zero-latency decimator'
            v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InvalidStructure',block.ftype));
        end
    end





    v=[v,validateFilterImplParams(this,hC)];
