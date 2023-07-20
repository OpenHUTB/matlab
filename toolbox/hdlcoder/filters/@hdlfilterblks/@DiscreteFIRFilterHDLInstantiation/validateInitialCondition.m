function v=validateInitialCondition(this,hC)






    v=hdlvalidatestruct;

    if~checkFilterBlkInitConds(this,hC);
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:filters:validate:initCondNotSupported'));
    end



