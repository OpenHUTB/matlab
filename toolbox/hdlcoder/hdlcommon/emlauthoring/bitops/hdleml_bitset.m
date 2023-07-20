%#codegen
function y=hdleml_bitset(wl,val,index,u)


    coder.allowpcode('plain')
    eml_prefer_const(wl);
    eml_prefer_const(val);
    eml_prefer_const(index);

    outLen=length(u);
    y=hdleml_define_len(u,outLen);

    if length(index)~=outLen
        eml_assert(0,'vector-length mismatch');
    end

    for ii=coder.unroll(1:outLen)

        switch index(ii)
        case wl
            y(ii)=bitconcat(fi(val,0,1,0),bitsliceget(u(ii),wl-1,1));
        case 1
            y(ii)=bitconcat(bitsliceget(u(ii),wl,2),fi(val,0,1,0));
        otherwise
            y(ii)=bitconcat(bitsliceget(u(ii),wl,index(ii)+1),fi(val,0,1,0),bitsliceget(u(ii),index(ii)-1,1));
        end
    end

