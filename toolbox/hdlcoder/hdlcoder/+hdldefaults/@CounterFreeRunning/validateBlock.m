
function v=validateBlock(~,hC)

    v=hdlvalidatestruct;

    counter_wl=str2double(get_param(hC.SimulinkHandle,'NumBits'));

    if(counter_wl>=128)
        errorStatus=1;
        v=hdlvalidatestruct(errorStatus,message('hdlcoder:validate:UnsupportedFreeRunningCounter'));
    end
    if hC.Owner.hasResettableInstances
        v(end+1)=hdlvalidatestruct(1,message('hdlcoder:validate:countercannotbereset'));
    end
end


