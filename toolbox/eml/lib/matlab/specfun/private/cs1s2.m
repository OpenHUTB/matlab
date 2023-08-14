function[s1,s2,iuf,nz]=cs1s2(zr,s1,s2,ascle,alim,iuf)











%#codegen

    coder.allowpcode('plain');
    as1=abs(s1);
    as2=abs(s2);
    if as1>0
        xx=real(zr);
        aln=-xx-xx+log(as1);
        if aln<(-alim)
            s1=complex(0);
            as1=0;
        else
            s1=log(s1);
            s1=s1-zr;
            s1=s1-zr;
            s1=exp(s1);
            as1=abs(s1);
            iuf=eml_plus(iuf,1,'int32','spill');
        end
    end
    if as1>ascle||as2>ascle
        nz=cast(0,'int32');
    else
        s1=complex(0);
        s2=complex(0);
        nz=cast(1,'int32');
        iuf(1)=0;
    end