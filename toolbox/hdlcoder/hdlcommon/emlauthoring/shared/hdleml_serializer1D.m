%#codegen
function dout=hdleml_serializer1D(ratio,in_vld,din,varargin)









    coder.allowpcode('plain')%#ok<EMXTR>
    eml_prefer_const(ratio);


    inLen=length(din);


    dimLen=inLen-1;

    persistent data
    if isempty(data)
        if coder.isenum(din)
            data=repmat(din(1),dimLen,1);
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
        for i=1:dimLen
            data(i)=din(i+1);
        end
    else
        for i=1:dimLen-1
            data(i)=data(i+1);
        end
        data(dimLen)=din(inLen);
    end
end


