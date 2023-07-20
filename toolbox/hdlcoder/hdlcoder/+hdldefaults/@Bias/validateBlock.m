
function v=validateBlock(this,hC)






    v=hdlvalidatestruct;

    inputType=hC.PirInputSignals(1).Type;
    if(inputType.BaseType.isRecordType())
        errorStatus=1;
        v=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:BiasBusBanned'));
    end

end
