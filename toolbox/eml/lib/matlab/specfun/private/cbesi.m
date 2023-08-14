function[cy,nz,ierr]=cbesi(z,fnu,kode)











%#codegen

    coder.allowpcode('plain');
    MINUSTWO=cast(-2,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    THREE=cast(3,'int32');
    FOUR=cast(4,'int32');
    FIVE=cast(5,'int32');

    ierr=ZERO;


    xx=real(z);
    yy=imag(z);









    TOL=eps('double');
    [base,mantissaLength,minExponent,maxExponent]=...
    coder.internal.floatModel('double');
    eml_assert(base==TWO,'The floating point base must be 2.');
    K1=coder.const(minExponent+ONE);
    K2=maxExponent;
    R1M5=coder.const(log10(2));
    K=coder.const(eml_min(abs(K1),abs(K2)));
    ELIM=coder.const(2.303*(double(K)*R1M5-3));
    K1=coder.const(mantissaLength-ONE);
    AA1=coder.const(R1M5*double(K1));
    DIG=coder.const(eml_min(AA1,18));
    AA2=coder.const(AA1*2.303);
    ALIM=coder.const(ELIM+eml_max(-AA2,-41.45));
    RL=coder.const(1.2*DIG+3);
    FNUL=coder.const(10+6*(DIG-3));
    AZ=abs(z);



    AA3=coder.const(0.5/TOL);
    BB=coder.const(double(intmax('int32'))*0.5);
    AA4=coder.const(eml_min(AA3,BB));

    fn=fnu;
    if AZ>AA4||fn>AA4
        ierr=FOUR;
    else
        AA5=coder.const(sqrt(AA4));
        if AZ>AA5||fn>AA5
            ierr=THREE;
        end
    end
    zn=z;
    csgn=complex(1);
    if xx<0
        zn=-z;


        inu=eml_cast(fnu,'int32','to zero','spill');
        arg=fnu-double(inu);
        if yy<0
            arg=-arg;
        end
        [carg,sarg]=coder.internal.scalar.cospiAndSinpi(arg);
        csgn=complex(carg,sarg);
        if eml_bitand(inu,ONE)==ONE
            csgn=-csgn;
        end
    end
    cy=complex(0);
    [cy,nz]=cbinu(zn,fnu,kode,cy,RL,FNUL,TOL,ELIM,ALIM);
    if nz<ZERO
        if nz==MINUSTWO
            nz=ZERO;
            ierr=FIVE;
            return
        end
        nz=ZERO;
        ierr=TWO;
        return
    end
    if xx>=0
        return
    end

    if nz~=ONE
        RTOL=1/TOL;
        ASCLE=realmin('double')*RTOL*1000;
        tmp=cy;
        if eml_max(abs(real(tmp)),abs(imag(tmp)))<=ASCLE
            tmp=tmp*RTOL;
            atol=TOL;
        else
            atol=1;
        end
        tmp=tmp*csgn;
        cy=tmp*atol;
    end

