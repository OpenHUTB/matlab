function[bi,ierr]=cbiry(z,id,kode)











%#codegen

    coder.allowpcode('plain');
    MINUSONE=cast(-1,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    THREE=cast(3,'int32');
    FOUR=cast(4,'int32');
    FIVE=cast(5,'int32');
    TWENTYFIVE=cast(25,'int32');
    bi=complex(0);
    ierr=ZERO;


    TTH=2/3;
    az=abs(z);
    TOL=eps('double');
    fid=double(id);
    if az>1

        fnu=(1+fid)/3;








        [base,mantissaLength,minExponent,maxExponent]=...
        coder.internal.floatModel('double');
        eml_assert(base==TWO,'The floating point base must be 2.');
        K1=coder.const(minExponent+ONE);
        K2=maxExponent;
        R1M5=log10(2);
        K=coder.const(eml_min(abs(K1),abs(K2)));
        ELIM=coder.const(2.303*(double(K)*R1M5-3));
        K1=coder.const(mantissaLength-ONE);
        AA1=coder.const(R1M5*double(K1));
        DIG=coder.const(eml_min(AA1,18));
        AA2=coder.const(AA1*2.303);
        ALIM=coder.const(ELIM+eml_max(-AA2,-41.45));
        RL=coder.const(1.2*DIG+3);
        FNUL=coder.const(10+6*(DIG-3));

        AA3=coder.const(0.5/TOL);
        bb=coder.const(double(intmax('int32'))*0.5);
        AA4=coder.const(eml_min(AA3,bb));
        AA5=coder.const(power(AA4,TTH));
        if az>AA5
            ierr=FOUR;
        else
            if az>coder.const(sqrt(AA5))
                ierr=THREE;
            end
        end
        csq=sqrt(complex(z));
        zta=z*csq;
        zta=zta*TTH;

        sfac=1;
        ak=imag(zta);
        if real(z)<0
            zta=complex(-abs(real(zta)),imag(zta));
        end
        if imag(z)==0&&real(z)<=0
            zta=complex(0,ak);
        end
        aa=real(zta);
        if kode~=TWO

            bb=abs(aa);
            if bb>=ALIM
                bb=bb+0.25*log(az);
                sfac=TOL;
                if bb>ELIM
                    ierr=TWO;
                    return
                end
            end
        end
        fmr=0;
        if~(aa>=0&&real(z)>0)
            if imag(z)<0.0
                fmr=-1;
            else
                fmr=1;
            end
            zta=-zta;
        end


        cy=complex(zeros(2,1));
        [cy,nz]=cbinu(zta,fnu,kode,cy,RL,FNUL,TOL,ELIM,ALIM);
        if nz<ZERO
            if nz==MINUSONE
                ierr=TWO;
            else
                ierr=FIVE;
            end
            return;
        end
        aa=fmr*fnu;
        z3=complex(sfac);
        [caa,saa]=coder.internal.scalar.cospiAndSinpi(aa);
        s1=complex(caa,saa);
        s1=s1*cy(1);
        s1=s1*z3;
        fnu=(2-fid)/3;
        cy=cbinu(zta,fnu,kode,cy,RL,FNUL,TOL,ELIM,ALIM);
        cy(1)=cy(1)*z3;
        cy(2)=cy(2)*z3;

        s2=cy(1)*(fnu+fnu);
        s2=s2/zta;
        s2=s2+cy(2);
        aa=fmr*(fnu-1);
        [caa,saa]=coder.internal.scalar.cospiAndSinpi(aa);
        tmp=complex(caa,saa);
        COEF=5.77350269189625765E-01;
        tmp=tmp*s2;
        s1=s1+tmp;
        s1=s1*COEF;
        if id==ONE
            s1=s1*z;
        else
            s1=s1*csq;
        end
        bi=s1*(1/sfac);
    else

        s1=complex(1);
        s2=complex(1);
        C1=6.14926627446000736E-01;
        C2=4.48288357353826359E-01;
        if az<TOL
            bi=complex(C1*(1-fid)+fid*C2,0);
            return
        end
        aa=az*az;
        if aa>=TOL/az
            trm1=complex(1);
            trm2=complex(1);
            atrm=1;
            z3=z*z;
            z3=z3*z;
            az3=az*aa;
            ak=2+fid;
            bk=3-fid-fid;
            ck=4-fid;
            dk=3+fid+fid;
            d1=ak*dk;
            d2=bk*ck;
            ad=eml_min(d1,d2);
            ak=24+9*fid;
            bk=30-9*fid;
            for k=ONE:TWENTYFIVE
                trm1=trm1*(z3/d1);
                s1=s1+trm1;
                trm2=trm2*(z3/d2);
                s2=s2+trm2;
                atrm=atrm*az3/ad;
                d1=d1+ak;
                d2=d2+bk;
                ad=eml_min(d1,d2);
                if atrm<TOL*ad
                    break
                end
                ak=ak+18;
                bk=bk+18;
            end
        end
        if id==ONE
            bi=s2*C2;
            if az>TOL
                tmp=z*z;
                tmp=tmp*s1;
                tmp=tmp*(C1/(1+fid));
                bi=bi+tmp;
            end
        else
            tmp=z*s2;
            tmp=tmp*C2;
            bi=s1*C1;
            bi=bi+tmp;
        end
        if kode~=ONE
            tmp=sqrt(z);
            tmp=tmp*z;
            tmp=tmp*TTH;
            bi=bi*exp(-abs(real(tmp)));
        end
    end

