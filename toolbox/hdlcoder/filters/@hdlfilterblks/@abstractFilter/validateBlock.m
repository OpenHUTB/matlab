function v=validateBlock(this,hC)





    v=hdlvalidatestruct;




    ip=hC.PirInputSignals(1);
    op=hC.PirOutputSignals(1);
    if(max(hdlsignalvector(ip))>1)||(max(hdlsignalvector(op)>1))
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:vectorport'));
    end


    v=[v,validateInitialCondition(this,hC)];


    if any([v.Status])
        return;
    end


    v=[v,validateFilterParams(this,hC)];
