%#codegen



function y=hdleml_hwdemux(u,ctr,factor)










    coder.allowpcode('plain')
    coder.internal.allowHalfInputs
    eml_prefer_const(factor);

    persistent yreg;
    if isempty(yreg)
        yreg=hdleml_init_len(u,factor);
    end

    ctr1=int32(int32(ctr)+int32(1));

    ytmp=hdleml_init_len(u,factor);

    for ii=coder.unroll(int32(1:factor))
        if ctr1==ii
            ytmp(ii)=u;
        else
            ytmp(ii)=yreg(ii);
        end
    end


    y=hdleml_init_len(u,factor);

    for ii=coder.unroll(int32(1:factor))
        yreg(ii)=ytmp(ii);
        y(ii)=ytmp(ii);
    end



end


