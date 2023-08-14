function[y,nz]=cbknu(z,fnu,kode,nin,y,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    n=eml_min(nin,numel(y));
    MINUSTWO=cast(-2,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    THREE=cast(3,'int32');
    EIGHT=cast(8,'int32');
    KMAX=cast(30,'int32');
    RTHPI=sqrt(pi/2);
    SPI=6/pi;
    HPI=pi/2;
    FPI=1.89769999331517738;
    TTH=2/3;
    CC=[...
    5.77215664901532861E-01,-4.20026350340952355E-02,...
    -4.21977345555443367E-02,7.21894324666309954E-03,...
    -2.15241674114950973E-04,-2.01348547807882387E-05,...
    1.13302723198169588E-06,6.11609510448141582E-09];
    xx=real(z);
    yy=imag(z);
    caz=abs(z);
    cssr=[1/tol,1,tol];
    csrr=[tol,1,1/tol];
    bry=[1000*realmin('double')/tol,...
    tol/(1000*realmin('double')),...
    realmax('double')];
    nz=ZERO;
    iflag=ZERO;
    koded=kode;
    rz=2/z;
    inu=eml_cast(fnu+0.5,'int32','to zero','spill');
    dnu=fnu-double(inu);
    goto_mw110=(abs(dnu)==0.5);
    if~goto_mw110&&abs(dnu)>tol
        dnu2=dnu*dnu;
    else
        dnu2=0;
    end
    p1=complex(0);
    ak=1;
    fhs=0;
    s1=complex(0);
    s2=complex(0);
    zd=complex(0);
    ck=complex(1);
    coef=complex(1);%#ok<NASGU> % added for compiler
    kflag=ZERO;%#ok<NASGU> % added for compiler
    inub=ONE;
    goto_mw225=false;
    goto_mw240=false;
    goto_mw270=false;
    goto_mw110=goto_mw110||caz>2;
    if~goto_mw110

        fc=1;
        smu=log(rz);
        fmu=smu*dnu;
        csh=sinh(fmu);
        cch=cosh(fmu);
        if dnu~=0
            fc=dnu*pi;
            fc=fc/sinpi(dnu);
            smu=csh*(1/dnu);
        end
        a2=1+dnu;

        t2=exp(-gammaln(a2));
        t1=1/(t2*fc);
        if abs(dnu)>0.1
            g1=(t1-t2)/(dnu+dnu);
        else

            ak=1;
            s=CC(1);
            for i=TWO:EIGHT
                ak=ak*dnu2;
                tm=CC(i)*ak;
                s=s+tm;
                if abs(tm)<tol
                    break
                end
            end
            g1=-s;
        end
        g2=0.5*(t1+t2)*fc;
        g1=g1*fc;
        tmp=g1*cch;
        f=smu*g2;
        f=f+tmp;
        pt=exp(fmu);
        p=pt*(0.5/t2);
        q=(0.5/t1)/pt;
        s1=f;
        s2=p;
        ak=1;
        a1=1;
        ck=complex(1);
        bk=1-dnu2;
        if~(inu>ZERO||n>ONE)

            if caz>=tol
                cz=z*z;
                cz=cz*0.25;
                t1=0.25*caz*caz;
                while true
                    f=f*ak;
                    f=f+p;
                    f=f+q;
                    f=f*(1/bk);
                    p=p*(1/(ak-dnu));
                    q=q*(1/(ak+dnu));
                    ck=ck*cz;
                    ck=ck*(1/ak);
                    tmp=ck*f;
                    s1=s1+tmp;
                    a1=a1*t1/ak;
                    bk=bk+ak+ak+1;
                    ak=ak+1;
                    if~(a1>tol)
                        break
                    end
                end
            end
            y(1)=s1;
            if koded~=ONE
                y(1)=exp(z);
                y(1)=y(1)*s1;
            end
            return
        end

        if caz>=tol
            cz=z*z;
            cz=cz*0.25;
            t1=0.25*caz*caz;
            while true
                f=f*ak;
                f=f+p;
                f=f+q;
                f=f*(1/bk);
                p=p*(1/(ak-dnu));
                q=q*(1/(ak+dnu));
                ck=ck*cz;
                ck=ck*(1/ak);
                tmp=ck*f;
                s1=s1+tmp;
                tmp=f*ak;
                tmp=p-tmp;
                tmp=tmp*ck;
                s2=s2+tmp;
                a1=a1*t1/ak;
                bk=bk+ak+ak+1;
                ak=ak+1;
                if~(a1>tol)
                    break
                end
            end
        end
        kflag=TWO;
        bk=real(smu);
        a1=fnu+1;
        ak=a1*abs(bk);
        if ak>alim
            kflag=THREE;
        end
        p2=s2*cssr(kflag);
        s2=p2*rz;
        s1=s1*cssr(kflag);
        if koded~=ONE
            f=exp(z);
            s1=s1*f;
            s2=s2*f;
        end
        goto_mw210=true;
    else
        goto_mw210=false;





        coef=complex(RTHPI/sqrt(z));
        kflag=TWO;
        if~(koded==TWO)
            if xx>alim


                iflag=ONE;
                kflag=TWO;
            else
                a1=exp(-xx)*cssr(kflag);
                pt=complex(cos(yy),sin(yy));
                pt=coder.internal.conjtimes(pt,a1);
                coef=coef*pt;
            end
        end
        if abs(dnu)==0.5
            s1=coef;
            s2=coef;
            goto_mw210=true;
        else

            ak=cospi(dnu);
            ak=abs(ak);
            if ak==0
                s1=coef;
                s2=coef;
                goto_mw210=true;
            else
                fhs=abs(0.25-dnu2);
                if fhs==0
                    s1=coef;
                    s2=coef;
                    goto_mw210=true;
                end
            end
        end
        if~goto_mw210




            t1=52.0*3.010299956639812e-01*3.321928094;
            t2=TTH*t1-6;
            if xx~=0
                t1=atan(yy/xx);
                t1=abs(t1);
            else
                t1=HPI;
            end
            if t2>caz

                a2=sqrt(caz);
                ak=FPI*ak/(tol*sqrt(a2));
                aa=3*t1/(1+caz);
                bb=14.7*t1/(28+caz);
                ak=(log(ak)+caz*cos(aa)/(1+0.008*caz))/cos(bb);
                fk=0.12125*ak*ak/caz+1.5;
            else

                etest=ak/(pi*caz*tol);
                fk=1;
                if etest>=1
                    fks=2;
                    rk=caz+caz+2;
                    a1=0;
                    a2=1;
                    earlyExit=true;
                    for i=ONE:KMAX
                        ak=fhs/fks;
                        bk=rk/(fk+1);
                        tm=a2;
                        a2=bk*a2-ak*a1;
                        a1=tm;
                        rk=rk+2;
                        fks=fks+fk+fk+2;
                        fhs=fhs+fk+fk;
                        fk=fk+1;
                        tm=abs(a2)*fk;
                        if etest<tm
                            earlyExit=false;
                            break
                        end
                    end
                    if earlyExit
                        nz=MINUSTWO;
                        return
                    end
                    fk=fk+SPI*t1*sqrt(t2/caz);
                    fhs=abs(0.25-dnu2);
                end
            end
            k=eml_cast(fix(fk),'int32','to zero','spill');

            fk=double(k);
            fks=fk*fk;
            p1=complex(0);
            p2=complex(tol,0);
            cs=p2;
            for i=ONE:k
                a1=fks-fk;
                a2=(fks+fk)/(a1+fhs);
                rk=2/(fk+1);
                t1=(fk+xx)*rk;
                t2=yy*rk;
                pt=p2;
                p2=p2*complex(t1,t2);
                p2=p2-p1;
                p2=p2*a2;
                p1=pt;
                cs=cs+p2;
                fks=a1-fk+1;
                fk=fk-1;
            end

            tm=abs(cs);
            pt=complex(1/tm,0);
            s1=pt*p2;
            cs=conj(cs);
            cs=cs*pt;
            s1=coef*s1;
            s1=s1*cs;
            if~(inu>0||n>1)
                zd=z;
                if iflag==ONE
                    goto_mw270=true;
                else
                    goto_mw240=true;
                end
            else

                tm=abs(p2);
                pt=complex(1/tm,0);
                p1=p1*pt;
                p2=conj(p2);
                p2=p2*pt;
                pt=p1*p2;
                tmp=(dnu+0.5)-pt;
                tmp=tmp/z;
                tmp=tmp+1;
                s2=s1*tmp;
                goto_mw210=true;
            end
        end
    end
    if goto_mw240||goto_mw270
    elseif goto_mw210



        ck=(dnu+1)*rz;
        if n==ONE
            inu=eml_minus(inu,ONE,'int32','spill');
        end
        if inu>0

            inub=ONE;
            if iflag==ONE

                helim=0.5*elim;
                elm=exp(-elim);
                celm=complex(elm);
                ascle=bry(1);
                zd=z;
                xd=xx;
                yd=yy;



                ic=cast(inu,'int32');
                j=TWO;

                cy=complex(zeros(2,1));
                for i=ONE:inu
                    st=s2;
                    s2=s2*ck;
                    s2=s2+s1;
                    s1=st;
                    ck=ck+rz;
                    as=abs(s2);
                    alas=log(as);
                    p2r=-xd+alas;
                    if p2r>=-elim
                        p2=log(s2);
                        tmp=-zd;
                        p2=p2+tmp;
                        tmp=complex(cos(imag(p2)),sin(imag(p2)));
                        p1=exp(real(p2))/tol*tmp;
                        nw=cuchk(p1,ascle,tol);
                        if nw==ZERO
                            j=eml_minus(THREE,j,'int32','spill');
                            cy(j)=p1;
                            if ic==eml_minus(i,ONE,'int32','spill')

                                kflag=ONE;
                                inub=eml_plus(i,ONE,'int32','spill');
                                s2=cy(j);
                                j=eml_minus(THREE,j,'int32','spill');
                                s1=cy(j);
                                if inub<=inu
                                    goto_mw225=true;
                                    break
                                end
                                if n==ONE
                                    s1=s2;
                                end
                                goto_mw240=true;
                                break
                            end
                            ic=i;
                            continue
                        end
                    end
                    if alas>=helim
                        xd=xd-elim;
                        s1=s1*celm;
                        s2=s2*celm;
                        zd=complex(xd,yd);
                    end
                end
                if~(goto_mw225||goto_mw240)
                    if n==ONE
                        s1=s2;
                    end
                    goto_mw270=true;
                end
            else
                goto_mw225=true;
            end
        end
        if~(goto_mw225||goto_mw240||goto_mw270)
            if n==ONE
                s1=s2;
            end
            zd=z;
            if iflag==ONE

            else
                goto_mw240=true;
            end
        end
    else
        goto_mw225=true;
    end
    if goto_mw225||goto_mw240
        if goto_mw225
            p1(1)=csrr(kflag);
            ascle=bry(kflag);
            for i=inub:inu
                st=s2;
                s2=s2*ck;
                s2=s2+s1;
                s1=st;
                ck=ck+rz;
                if kflag<3
                    p2=s2*p1;
                    p2m=eml_max(abs(real(p2)),abs(imag(p2)));
                    if p2m>ascle
                        kflag=eml_plus(kflag,ONE,'int32','spill');
                        ascle=bry(kflag);
                        s1=s1*p1;
                        s2=p2;
                        s1=s1*cssr(kflag);
                        s2=s2*cssr(kflag);
                        p1(1)=csrr(kflag);
                    end
                end
            end
            if n==ONE
                s1=s2;
            end
        end

        y(1)=s1*csrr(kflag);
        if n==TWO&&numel(y)>1
            y(n)=s2*csrr(kflag);
        end
    else
        y(1)=s1;
        if n~=ONE&&numel(y)>1
            y(2)=s2;
        end
        ascle=bry(1);
        [y,nz]=ckscl(zd,n,y,ascle,tol,elim);
        if n<=nz
            return
        end
        inu=n-nz;
        nzp1=eml_plus(nz,ONE,'int32','spill');
        s1=y(nzp1);
        y(nzp1)=s1*csrr(1);
        if inu>=TWO
            nzp2=eml_plus(nz,TWO,'int32','spill');
            s2=y(nzp2);
            y(nzp2)=s2*csrr(1);
        end
    end



    function[y,nz]=ckscl(zr,nin,y,ascle,tol,elim)











%#codegen

        n=eml_min(nin,numel(y));
        ZERO=cast(0,'int32');
        ONE=cast(1,'int32');
        TWO=cast(2,'int32');
        ic=ZERO;
        nz=ZERO;
        if n>=ONE
            s1=y(1);
            nz=ONE;
            y(1)=0;
            acs=-real(zr)+log(abs(s1));
            if acs>=-elim
                cs=calccs(zr,s1,tol);
                nw=cuchk(cs,ascle,tol);
                if nw==ZERO
                    y(1)=cs;
                    nz=ZERO;
                    ic=ONE;
                end
            end
        end
        if n==TWO
            if nz==ONE
                nz=TWO;
            else
                nz=ONE;
            end
            s1=y(2);
            y(2)=0;
            acs=-real(zr)+log(abs(s1));
            if acs>=-elim
                cs=calccs(zr,s1,tol);
                nw=cuchk(cs,ascle,tol);
                if nw==ZERO
                    y(2)=cs;

                    if nz==TWO
                        nz=ONE;
                    else
                        nz=ZERO;
                    end
                    ic=TWO;
                end
            end
            if ic<TWO
                y(1)=0;
                nz=TWO;
            end
        end



        function cs=calccs(zr,s1,tol)
            cs=-zr;
            tmp=log(s1);
            cs=cs+tmp;
            aa=exp(real(cs))/tol;
            tmp=complex(cos(imag(cs)),sin(imag(cs)));
            cs=aa*tmp;


