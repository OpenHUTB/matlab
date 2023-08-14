
function v=validateBlock(~,hC)

    v=hdlvalidatestruct;

    if hC.Owner.hasResettableInstances
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:countercannotbereset'));
    end
end


