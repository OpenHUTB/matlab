%#codegen
function[y,y_idx]=hdleml_min_vector_valandidx(u,u_idx)





    coder.allowpcode('plain')

    inputLen=length(u);
    outLen=ceil(inputLen/2);
    numOps=floor(inputLen/2);



    y=hdleml_define_len(u,outLen);
    y_idx=hdleml_define_len(u_idx,outLen);
    isless=hdleml_define_len(true,numOps);


    for ii=coder.unroll(1:numOps)
        if(u(ii*2-1)<=u(ii*2))
            isless(ii)=true;
        else
            isless(ii)=false;
        end

        if isless(ii)==true
            y(ii)=u(ii*2-1);
            y_idx(ii)=u_idx(ii*2-1);
        else
            y(ii)=u(ii*2);
            y_idx(ii)=u_idx(ii*2);
        end
    end


    inputLenOdd=(mod(inputLen,2)==1);
    if inputLenOdd
        y(end)=u(end);
        y_idx(end)=u_idx(end);
    end

