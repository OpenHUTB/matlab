function[y,nz]=cacon(z,fnu,kode,mr,y,rl,fnul,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(fnu,kode,mr,rl,fnul,tol,elim,alim);
    ONE=int32(1);
    nz=int32(0);
    zn=-z;

    [y,nw]=cbinu(zn,fnu,kode,y,rl,fnul,tol,elim,alim);
    if nw<0
        nz=int32(-1);
        if nw==-2
            nz=int32(-2);
        end
        return
    end

    cy=complex(0);

    [cy,nw]=cbknu(zn,fnu,kode,ONE,cy,tol,elim,alim);
    if nw~=0
        nz=int32(-1);
        if nw==int32(-2)
            nz=int32(-2);
        end
        return
    end
    s1=cy(1);
    fmr=double(mr);
    inu=eml_cast(fnu,'int32','to zero','spill');
    if fmr<0
        arg=fnu-double(inu);
        csgn=complex(0,pi);
    else
        arg=-(fnu-double(inu));
        csgn=complex(0,-pi);
    end
    if kode~=1
        cpn=cos(-imag(zn));
        spn=sin(-imag(zn));
        csgn=csgn*complex(cpn,spn);
    end


    [cpn,spn]=coder.internal.scalar.cospiAndSinpi(arg);
    cspn=complex(cpn,spn);
    if rem(inu,int32(2))==1
        cspn=-cspn;
    end
    iuf=int32(0);
    c1=s1;
    c2=y(1);
    ascle=1000*realmin/tol;
    if kode~=1

        [c1,c2,~,nw]=cs1s2(zn,c1,c2,ascle,alim,iuf);
        nz=nz+nw;
    end
    tmp=cspn*c1;
    y(1)=csgn*c2+tmp;

