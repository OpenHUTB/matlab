%#codegen
function[doutx,dout]=hdleml_cascade_serializer(in_vld,din)











    coder.allowpcode('plain')
    eml_prefer_const(din);

    inputLen=length(din);
    eml_assert(inputLen>=3,'No need to use serializer for input vector dimension less than 3.');


    dimLen=inputLen-2;

    persistent data


    if isempty(data)
        if isfloat(din)
            if(isreal(din))
                data=zeros(dimLen,1);
            else
                data=complex(zeros(dimLen,1),zeros(dimLen,1));
            end
        else
            nt=numerictype(din);
            fm=fimath(din);
            if(isreal(din))
                data=fi(zeros(dimLen,1),nt,fm);
            else
                data=fi(complex(zeros(dimLen,1),zeros(dimLen,1)),nt,fm);
            end
        end
    end


    doutx=din(1);


    if in_vld
        dout=din(2);
    else
        dout=data(1);
    end


    if in_vld
        for i=coder.unroll(1:dimLen-1)
            data(i)=din(i+2);
        end
    else
        for i=coder.unroll(1:dimLen-1)
            data(i)=data(i+1);
        end
    end

    data(dimLen)=din(dimLen+2);
