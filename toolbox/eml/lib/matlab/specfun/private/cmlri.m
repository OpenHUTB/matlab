function[y,nz]=cmlri(z,fnu,kode,nin,y,tol)











%#codegen

    coder.allowpcode('plain');
    n=eml_min(nin,numel(y));
    MINUSTWO=cast(-2,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    EIGHTY=cast(80,'int32');
    scle=1000*realmin('double')/tol;
    nz=ZERO;
    az=abs(z);
    flooraz=floor(az);
    iaz=eml_cast(flooraz,'int32','to zero','spill');
    fixfnu=fix(fnu);
    ifnu=eml_cast(fixfnu,'int32','to zero','spill');
    inu=eml_minus(eml_plus(ifnu,n,'int32','spill'),ONE,'int32','spill');
    at=flooraz+1;
    ck=at/z;
    rz=2/z;
    p1=complex(0);
    p2=complex(1);
    ack=(at+1)/az;
    rho=ack+sqrt(ack*ack-1);
    rho2=rho*rho;
    tst=(rho2+rho2)/((rho2-1)*(rho-1));
    tst=tst/tol;

    ak=at;
    earlyExit=true;
    icounter=ZERO;
    for i=ONE:EIGHTY
        icounter=eml_plus(icounter,ONE,'int32','spill');
        pt=p2;
        tmp=ck*p2;
        p2=p1-tmp;
        p1=pt;
        ck=ck+rz;
        ap=abs(p2);
        if ap>tst*ak*ak
            earlyExit=false;
            break
        end
        ak=ak+1;
    end
    if earlyExit
        nz=MINUSTWO;
        return
    end
    icounter=eml_plus(icounter,ONE,'int32','spill');
    kcounter=ZERO;
    if inu>=iaz

        p1(1)=0;
        p2(1)=1;
        at=double(inu)+1;
        ck=at/z;
        ack=at/az;
        tst=sqrt(ack/tol);
        itime=ONE;
        earlyExit=true;
        for i=ONE:EIGHTY
            kcounter=eml_plus(kcounter,ONE,'int32','spill');
            pt=p2;
            tmp=ck*p2;
            p2=p1-tmp;
            p1=pt;
            ck=ck+rz;
            ap=abs(p2);
            if ap>=tst*ak*ak
                if itime==TWO
                    earlyExit=false;
                    break
                end
                ack=abs(ck);
                flam=ack+sqrt(ack*ack-1);
                fkap=ap/abs(p1);
                rho=eml_min(flam,fkap);
                tst=tst*sqrt(rho/(rho*rho-1));
                itime=TWO;
            end
        end
        if earlyExit
            nz=MINUSTWO;
            return
        end
    end

    kcounter=eml_plus(kcounter,ONE,'int32','spill');
    kk1=eml_plus(icounter,iaz,'int32','spill');
    kk2=eml_plus(kcounter,inu,'int32','spill');
    kk=eml_max(kk1,kk2);
    fkk=double(kk);
    p1(1)=0;

    p2(1)=scle;
    fnf=fnu-fixfnu;
    tfnf=fnf+fnf;
    bk=gammaln(fkk+tfnf+1)-gammaln(fkk+1)-gammaln(tfnf+1);
    bk=exp(bk);
    s=complex(0);
    km=eml_minus(kk,inu,'int32','spill');
    for i=ONE:km
        pt=p2;
        tmp=(fkk+fnf)*rz;
        tmp=tmp*p2;
        p2=p1+tmp;
        p1=pt;
        ak=1-tfnf/(fkk+tfnf);
        ack=bk*ak;
        tmp=(ack+bk)*p1;
        s=s+tmp;
        bk=ack;
        fkk=fkk-1;
    end
    y(n)=p2;
    if n~=ONE
        for i=2:n
            pt=p2;
            tmp=(fkk+fnf)*rz;
            tmp=tmp*p2;
            p2=p1+tmp;
            p1=pt;
            ak=1-tfnf/(fkk+tfnf);
            ack=bk*ak;
            tmp=(ack+bk)*p1;
            s=s+tmp;
            bk=ack;
            fkk=fkk-1;
            m=eml_plus(eml_minus(n,i,'int32','spill'),ONE,'int32','spill');
            y(m)=p2;
        end
    end
    if ifnu>ZERO
        for i=ONE:ifnu
            pt=p2;
            tmp=(fkk+fnf)*rz;
            tmp=tmp*p2;
            p2=p1+tmp;
            p1=pt;
            ak=1-tfnf/(fkk+tfnf);
            ack=bk*ak;
            tmp=(ack+bk)*p1;
            s=s+tmp;
            bk=ack;
            fkk=fkk-1;
        end
    end
    pt(1)=z;
    if kode==TWO
        pt=pt-real(z);
    end
    tmp=log(rz);
    tmp=complex(-fnf,-0)*tmp;
    p1=tmp+pt;
    ap=gammaln(1+fnf);
    pt=p1-ap;


    p2=p2+s;
    ap=abs(p2);
    p1=complex(1/ap,0);
    tmp=exp(pt);
    ck=tmp*p1;
    pt=coder.internal.conjtimes(p2,p1);
    cnorm=ck*pt;
    for i=ONE:n
        y(i)=y(i)*cnorm;
    end
