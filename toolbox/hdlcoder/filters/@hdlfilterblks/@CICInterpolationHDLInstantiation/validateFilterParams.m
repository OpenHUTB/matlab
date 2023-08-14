function v=validateFilterParams(this,hC)


    v=hdlvalidatestruct;

    bfp=hC.SimulinkHandle;
    block=get_param(bfp,'Object');
    switch block.ftype
    case 'Zero-latency decimator'
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:InvalidStructure',block.ftype));
    end





    v=[v,validateFilterImplParams(this,hC)];
