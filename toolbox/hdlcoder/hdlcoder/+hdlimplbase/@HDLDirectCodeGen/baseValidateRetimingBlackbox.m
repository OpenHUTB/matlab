function v=baseValidateRetimingBlackbox(this,hN)



    v=hdlvalidatestruct;

    if hN.getDistributedPipelining
        v=hdlvalidatestruct(2,message('hdlcoder:validate:blackBoxInDistPipe'));
    end
