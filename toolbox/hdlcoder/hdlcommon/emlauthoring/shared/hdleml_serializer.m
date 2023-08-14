%#codegen
function dout=hdleml_serializer(din,in_vld,sleepCycles,initValue)









    coder.allowpcode('plain')
    eml_prefer_const(sleepCycles);


    inLen=length(din);
    inputLen=inLen+sleepCycles;
    eml_assert(inputLen>=2,'No need to use serializer for scalar input.');


    dimLen=inputLen-1;

    persistent data
    if isempty(data)
        if coder.isenum(initValue)
            data=initValue;
        else
            data=hdleml_init_len(din,dimLen);
        end
    end


    if in_vld
        dout=din(1);
    else
        dout=data(1);
    end


    if in_vld
        if sleepCycles==0
            for i=1:dimLen-1
                data(i)=din(i+1);
            end
        else
            for i=1:inLen-1
                data(i)=din(i+1);
            end
            for i=inLen:dimLen-1
                data(i)=hdleml_init_len(din,1);
            end
        end
    else
        for i=1:dimLen-1
            data(i)=data(i+1);
        end
    end

    data(dimLen)=din(inLen);
end


