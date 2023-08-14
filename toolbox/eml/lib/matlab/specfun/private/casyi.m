function[y,nz]=casyi(z,fnu,kode,nin,y,rl,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    n=eml_min(nin,cast(numel(y),'int32'));
    MINUSTWO=cast(-2,'int32');
    MINUSONE=cast(-1,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    nz=ZERO;
    az=abs(z);
    x=real(z);
    ARM=1000*realmin('double');
    RTR1=sqrt(ARM);
    if n<TWO
        il=n;
        dfnu=fnu;
    else
        il=TWO;
        dfnu=fnu+double(eml_minus(n,TWO,'int32','spill'));
    end

    RTPI=0.159154943091895336;
    ak1=sqrt(complex(RTPI/z));
    if kode==2
        cz=complex(0,imag(z));
        acz=0;
    else
        cz=complex(z);
        acz=real(z);
    end
    absacz=abs(acz);
    if absacz>elim
        nz=MINUSONE;
        y(:)=complex(coder.internal.nan('like',z));
        return
    end
    dnu2=dfnu+dfnu;

    if absacz>alim&&n>TWO
    else

        tmp=exp(cz);
        ak1=ak1*tmp;
    end
    fdn=0;
    if dnu2>RTR1
        fdn=dnu2*dnu2;
    end
    ez=z*8;



    aez=8*az;
    s=tol/aez;
    jl=eml_cast(fix(rl+rl),'int32','to zero','spill');
    jl=eml_plus(jl,TWO,'int32','spill');
    yy=imag(z);
    if yy~=0


        inu=eml_cast(fnu,'int32','to zero','spill');
        [bk,ak]=coder.internal.scalar.cospiAndSinpi(fnu-double(inu));
        if yy<0
            bk=-bk;
        end
        if eml_bitand(inu,ONE)
            p1=complex(ak,-bk);
        else
            p1=complex(-ak,bk);
        end
    else
        p1=complex(0);
    end
    for k=1:il
        sqk=fdn-1;
        atol=s*abs(sqk);
        sgn=1;
        cs1=complex(1);
        cs2=complex(1);
        ck=complex(1);
        ak=0;
        aa=1;
        bb=aez;
        dk=ez;
        errflag=true;
        for i=ONE:jl
            ck=ck*sqk;
            ck=ck/dk;
            cs2=cs2+ck;
            sgn=-sgn;
            tmp=ck*sgn;
            cs1=cs1+tmp;
            dk=dk+ez;
            aa=aa*abs(sqk)/bb;
            bb=bb+aez;
            ak=ak+8;
            sqk=sqk-ak;
            if aa<=atol
                errflag=false;
                break
            end
        end
        if errflag
            nz=MINUSTWO;
            return
        end
        s2=cs1;
        if(x+x)<elim
            tmp=-2*z;
            tmp=exp(tmp);
            tmp=tmp*cs2;
            tmp=tmp*p1;
            s2=s2+tmp;
        end
        fdn=fdn+8*dfnu+4;
        p1=-p1;

        m=eml_plus(eml_minus(n,il,'int32','spill'),k,'int32','spill');
        y(m)=s2*ak1;
    end
