function[ai,nz,ierr]=cairy(z,id,kode)











%#codegen

    coder.allowpcode('plain');
    MINUSONE=cast(-1,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    THREE=cast(3,'int32');
    FOUR=cast(4,'int32');
    FIVE=cast(5,'int32');
    ai=complex(0);
    cy=complex(0);
    ierr=ZERO;
    nz=ZERO;


    TTH=2/3;
    C1=3.55028053887817240e-01;
    C2=2.58819403792806799e-01;
    COEF=1.83776298473930683e-01;
    az=abs(z);
    TOL=eps('double');
    FID=double(id);
    if az>1

        FNU=(1+FID)/3;








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
        ALAZ=log(az);

        AA3=coder.const(0.5/TOL);
        BB=coder.const(double(intmax('int32'))*0.5);
        AA4=coder.const(eml_min(AA3,BB));
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

        iflag=ZERO;
        sfac=1;
        ak=imag(zta);
        if real(z)<0
            zta=complex(-abs(real(zta)),ak);
        end
        if imag(z)~=0||real(z)>0

        else
            zta=complex(0,ak);
        end
        aa=real(zta);
        if aa>=0&&real(z)>0
            if kode~=TWO

                if aa>=ALIM
                    aa=-aa-0.25*ALAZ;
                    iflag=TWO;
                    sfac=1/TOL;
                    if aa<-ELIM
                        nz=ONE;
                        return
                    end
                end
            end

            [cy,nz]=cbknu(zta,FNU,kode,ONE,cy,TOL,ELIM,ALIM);
        else
            if kode~=TWO

                if aa<=-ALIM
                    aa=-aa+0.25*ALAZ;
                    iflag=ONE;
                    sfac=TOL;
                    if aa>ELIM
                        nz=ZERO;
                        ierr=TWO;
                        return
                    end
                end
            end

            if imag(z)<0
                mr=MINUSONE;
            else
                mr=ONE;
            end
            [cy,nn]=cacai(zta,FNU,kode,mr,cy,RL,TOL,ELIM,ALIM);
            if nn<ZERO
                nz=ZERO;
                if nn==MINUSONE
                    ierr=TWO;
                else
                    ierr=FIVE;
                end
                return
            end
            nz=nz+nn;
        end
        s1=COEF*cy;
        if iflag~=ZERO
            s1=s1*sfac;
            if id==ONE
                s1=-s1;
                s1=s1*z;
            else
                s1=s1*csq;
            end
            ai=s1*(1/sfac);
            return
        end
        if id==ONE
            ai=-z;
            ai=ai*s1;
        else
            ai=csq*s1;
        end
        return
    end

    s1=complex(1);
    s2=complex(1);
    if az<TOL
        aa=1000*realmin('double');
        s1=complex(0);
        if id==ONE
            ai=-complex(C2);
            aa=sqrt(aa);
            if az>aa
                s1=z*z;
                s1=s1*0.5;
            end
            s1=s1*C1;
            ai=ai+s1;
            return
        end
        if az>aa
            s1=C2*z;
        end
        ai=C1-s1;
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
        ak=2+FID;
        bk=3-FID-FID;
        ck=4-FID;
        dk=3+FID+FID;
        d1=ak*dk;
        d2=bk*ck;
        ad=eml_min(d1,d2);
        ak=24+9*FID;
        bk=30-9*FID;
        for i=ONE:cast(25,'int32')
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
        ai=(-C2)*s2;
        if az>TOL
            tm=z*z;
            tm=tm*s1;
            tm=tm*(C1/(1+FID));
            ai=ai+tm;
        end
        if kode==ONE
            return
        end
        zta=sqrt(z);
        zta=zta*z;
        zta=zta*TTH;
        zta=exp(zta);
        ai=ai*zta;
    else
        ai=s1*C1;
        tm=z*s2;
        tm=tm*C2;
        ai=ai-tm;
        if kode==ONE
            return
        end
        zta=sqrt(z);
        zta=zta*z;
        zta=zta*TTH;
        zta=exp(zta);
        ai=ai*zta;
    end



    function[y,nz]=cacai(z,fnu,kode,mr,y,rl,tol,elim,alim)











%#codegen

        n=cast(numel(y),'int32');
        MINUSTWO=cast(-2,'int32');
        MINUSONE=cast(-1,'int32');
        ZERO=cast(0,'int32');
        ONE=cast(1,'int32');
        nz=ZERO;
        zn=-z;
        az=abs(z);
        nn=n;
        dfnu=fnu+double(n)-1;
        if~(az<=2)&&az*az*0.25>dfnu+1
            if az<rl


                [y,nw]=cmlri(zn,fnu,kode,nn,y,tol);
            else


                [y,nw]=casyi(zn,fnu,kode,nn,y,rl,tol,elim,alim);
            end
            if nw<ZERO
                if nw==MINUSTWO
                    nz=MINUSTWO;
                else
                    nz=MINUSONE;
                end
                return
            end
        else


            y=cseri(zn,fnu,kode,nn,y,tol,elim,alim);
        end


        cy=complex(zeros(2,1));
        [cy,nw]=cbknu(zn,fnu,kode,ONE,cy,tol,elim,alim);
        if nw~=ZERO
            if nw==MINUSTWO
                nz=MINUSTWO;
            else
                nz=MINUSONE;
            end
            return
        end
        fmr=double(mr);
        if fmr<0
            sgn=1;
        else
            sgn=-1;
        end
        csgn=complex(0,sgn*pi);
        if kode~=ONE
            tmp=complex(cos(-imag(zn)),sin(-imag(zn)));
            csgn=csgn*tmp;
        end


        inu=eml_cast(fnu,'int32','to zero','spill');
        arg=(fnu-double(inu))*sgn;
        [carg,sarg]=coder.internal.scalar.cospiAndSinpi(arg);
        cspn=complex(carg,sarg);
        if eml_bitand(inu,ONE)
            cspn=-cspn;
        end
        c1=cy(1);
        c2=y(1);
        if kode~=ONE
            iuf=ZERO;
            ascle=1000*realmin('double')/tol;
            [c1,c2,~,nw]=cs1s2(zn,c1,c2,ascle,alim,iuf);
            nz=nz+nw;
        end
        tmp=cspn*c1;
        y(1)=csgn*c2;
        y(1)=y(1)+tmp;


