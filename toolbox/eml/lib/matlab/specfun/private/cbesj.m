function[cy,nz,ierr]=cbesj(z,fnu,kode)











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

    TOL=eps('double');
    R1M5=coder.const(log10(2));
    [base,mantissaLength,~,maxExponent]=coder.internal.floatModel('double');
    eml_assert(base==TWO,'The floating point base must be 2.');
    ELIM=coder.const(2.303*(double(maxExponent-1)*R1M5-3));
    DIG=coder.const(R1M5*double(mantissaLength-1));
    ALIM=coder.const(ELIM-DIG*2.303);
    RL=coder.const(1.2*DIG+3);
    FNUL=coder.const(10+6*(DIG-3));
    ci=1i;
    yy=imag(z);
    az=abs(z);

    AA1=coder.const(double(intmax('int32'))*0.5);
    FN=fnu;
    if az>AA1||FN>AA1
        ierr=FOUR;
    else
        AA2=coder.const(sqrt(AA1));
        if az>AA2||FN>AA2
            ierr=THREE;
        end
    end


    inu=eml_cast(fnu,'int32','to zero','spill');
    inuh=eml_rshift(inu,ONE);
    ir=eml_minus(inu,eml_lshift(inuh,ONE),'int32','spill');
    arg=(fnu-double(eml_minus(inu,ir,'int32','spill')))*0.5;
    [carg,sarg]=coder.internal.scalar.cospiAndSinpi(arg);
    csgn=complex(carg,sarg);
    if eml_bitand(inuh,ONE)==ONE
        csgn=-csgn;
    end

    zn=-z*ci;
    if yy<0
        zn=-zn;
        csgn=conj(csgn);

    end
    cy=complex(0);
    [cy,nz]=cbinu(zn,fnu,kode,cy,RL,FNUL,TOL,ELIM,ALIM);
    if nz<ZERO
        if nz==MINUSTWO
            nz=ZERO;
            ierr=FIVE;
            cy=complex(coder.internal.nan,coder.internal.nan);
            return
        end
        nz=ZERO;
        ierr=TWO;
        cy=complex(coder.internal.inf,0);
        return
    end
    if nz~=ONE
        RTOL=coder.const(1/TOL);
        ASCLE=coder.const(realmin('double')*RTOL*1000);
        zn=cy;

        if eml_max(abs(real(zn)),abs(imag(zn)))<=ASCLE
            zn=zn*RTOL;
            atol=TOL;
        else
            atol=1;
        end
        zn=zn*csgn;
        cy=zn*atol;
    end
