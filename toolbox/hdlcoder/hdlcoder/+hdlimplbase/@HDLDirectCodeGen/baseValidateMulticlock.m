function v=baseValidateMulticlock(~,~)



    v=hdlvalidatestruct;
    if hdlgetparameter('clockinputs')==2
        v=hdlvalidatestruct(1,...
        message('hdlcoder:validate:archNotValidForMulticlock'));
    end

end
