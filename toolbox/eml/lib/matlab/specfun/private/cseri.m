function[y,nz]=cseri(z,fnu,kode,nin,y,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    n=eml_min(nin,numel(y));
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    nz=ZERO;
    az=abs(z);
    if az==0
        if fnu==0
            y(1)=1;
        else
            y(1)=0;
        end
        for i=TWO:n
            y(i)=0;
        end
        return
    end
    x=real(z);
    arm=1000*realmin('double');
    rtr1=sqrt(arm);
    crsc=complex(1);
    iflag=false;
    if az<arm
        nz=n;
        if fnu==0
            nz=eml_minus(nz,ONE,'int32','spill');
        end
        if fnu==0
            y(1)=1;
        else
            y(1)=0;
        end
        for i=TWO:n
            y(i)=0;
        end
        return
    end
    hz=z*0.5;
    if az>rtr1
        cz=complex(hz*hz);
        acz=abs(cz);
    else
        cz=complex(0);
        acz=0;
    end
    ck=log(hz);
    dfnu=fnu+double(n)-1;
    fnup=dfnu+1;

    ak1=ck*dfnu;
    ak=gammaln(fnup);
    ak1=ak1-ak;
    if kode==2
        ak1=ak1-x;
    end
    rak1=real(ak1);
    if rak1>-elim

        ascle=0;
        if rak1<=-alim
            iflag=true;
            crsc=complex(tol);
            ascle=arm/tol;
        end
        ak=imag(ak1);
        aa=exp(rak1);
        if iflag
            aa=aa/tol;
        end
        coef=aa*complex(cos(ak),sin(ak));
        atol=tol*acz/fnup;
        il=eml_min(TWO,n);
        w=complex(zeros(2,1));
        for i=ONE:il
            dfnu=fnu+double(eml_minus(n,i,'int32','spill'));
            fnup=dfnu+1;
            s1=complex(1);
            if~(acz<tol*fnup)
                ak1=complex(1);
                ak=fnup+2;
                s=fnup;
                aa=2;
                while true
                    rs=1/s;
                    ak1=ak1*cz;
                    ak1=ak1*rs;
                    s1=s1+ak1;
                    s=s+ak;
                    ak=ak+2;
                    aa=aa*acz*rs;
                    if~(aa>atol)
                        break
                    end
                end
            end

            m=eml_plus(eml_minus(n,i,'int32','spill'),ONE,'int32','spill');
            s2=s1*coef;
            w(i)=s2;
            if iflag
                nw=cuchk(s2,ascle,tol);
                if nw~=ZERO
                    break
                end
            end
            y(m)=s2*crsc;
            if i~=il
                coef=coef*dfnu;
                coef=coef/hz;
            end
        end
    else

        nz=eml_plus(nz,ONE,'int32','spill');
        y(n)=0;
        if acz>dfnu


            nz=-nz;
        end
    end
