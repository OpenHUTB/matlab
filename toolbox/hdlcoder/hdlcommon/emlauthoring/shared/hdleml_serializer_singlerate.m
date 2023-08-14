%#codegen
function serial_out=hdleml_serializer_singlerate(parallel_in,in_vld,serial_enb,initValue)






    coder.allowpcode('plain')


    inputLen=length(parallel_in);
    eml_assert(inputLen>=2,'No need to use serializer for scalar input.');

    persistent data
    if isempty(data)
        if coder.isenum(initValue)
            data=initValue;
        else
            data=hdleml_init_len(parallel_in,inputLen);
        end
    end


    serial_out=data(1);



    if in_vld
        for i=1:inputLen
            data(i)=parallel_in(i);
        end
    elseif serial_enb
        for i=1:inputLen-1
            data(i)=data(i+1);
        end
    end
end


