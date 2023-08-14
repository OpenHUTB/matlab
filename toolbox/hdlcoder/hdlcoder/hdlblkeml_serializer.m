function[dout,dvalid]=hdlblkeml_serializer(din,inputLen,serialFactor,...
    EnumInit)

%#codegen
    coder.allowpcode('plain');

    persistent cnt
    if isempty(cnt)
        cnt=int32(0);
    end


    dvalid=cnt==0;


    if coder.isenum(din)
        din_conv=din;
    else
        din_conv=cast_to_fi(din);
    end
    dout=hdl_serializer(din_conv,dvalid,serialFactor,EnumInit);


    if cnt==int32(inputLen/serialFactor-1)
        cnt=int32(0);
    else
        cnt=cnt+int32(1);
    end

end


function dout=hdl_serializer(din,in_vld,serialFactor,EnumInit)


    inLen=length(din);
    if inLen==1
        dout=din;
        return;
    end

    [mdim,ndim]=size(din);
    if mdim>ndim
        colvec=true;
    else
        colvec=false;
    end


    bufferLength=inLen/serialFactor-1;
    bufferWidth=serialFactor;

    persistent data
    if isempty(data)
        if coder.isenum(din)
            data=repmat(EnumInit,bufferLength,bufferWidth);
        else
            data=hdleml_init_len(din,bufferLength,bufferWidth);
        end
    end


    if in_vld
        dout=din(1:bufferWidth);
    else
        if colvec
            dout=data(1,:).';
        else
            dout=data(1,:);
        end
    end


    if in_vld
        for i=coder.unroll(1:bufferLength-1)
            data(i,:)=din(i*bufferWidth+1:i*bufferWidth+bufferWidth);
        end
    else
        for i=1:bufferLength-1
            data(i,:)=data(i+1,:);
        end
    end

    data(bufferLength,:)=din(bufferLength*bufferWidth+1:end);
end



function y=hdleml_init_len(u,outLen,outWidth)
    if isreal(u)
        y=hdleml_init_real(u,outLen,outWidth);
    else
        y_r=hdleml_init_real(real(u),outLen,outWidth);
        y=complex(y_r,y_r);
    end
end


function y=hdleml_init_real(u,outLen,outWidth)
    if islogical(u)
        y=logical(zeros(outLen,outWidth));%#ok<LOGL>
    elseif isa(u,'double')
        y=zeros(outLen,outWidth);
    elseif isa(u,'single')
        y=single(zeros(outLen,outWidth));
    else
        y=fi(zeros(outLen,outWidth),numerictype(u),fimath(u));
    end
end


