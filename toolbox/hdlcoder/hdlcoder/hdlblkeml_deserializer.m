function dout=hdlblkeml_deserializer(din,outputLen,serialFactor)
%#codegen



    coder.allowpcode('plain')


    inLen=length(din);
    eml_assert(inLen==serialFactor,...
    'Serialize Factor specified in DeSerializer block does not match with its input vector size.');

    [mdim,ndim]=size(din);
    if inLen==1
        colvec=true;
    else
        if mdim>ndim
            colvec=true;
        else
            colvec=false;
        end
    end


    bufferLength=outputLen/serialFactor;
    bufferWidth=serialFactor;

    persistent data
    if isempty(data)
        data=hdleml_init_len(din,bufferLength,bufferWidth);
    end


    if colvec
        dout=hdleml_init_len(din,outputLen,1);
    else
        dout=hdleml_init_len(din,1,outputLen);
    end
    for i=eml.unroll(0:bufferLength-1)
        dout(i*bufferWidth+1:i*bufferWidth+bufferWidth)=data(i+1,:);
    end


    for i=1:bufferLength-1
        data(i,:)=data(i+1,:);
    end
    data(bufferLength,:)=din;

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

