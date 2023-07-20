function[cy,nz]=cbinu(z,fnu,kode,cy,rl,fnul,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    n=cast(numel(cy),'int32');
    MINUSONE=cast(-1,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');
    nz=ZERO;
    az=abs(z);
    nn=n;
    dfnu=fnu;
    if az<=2||az*az*0.25<=dfnu+1

        [cy,nw]=cseri(z,fnu,kode,nn,cy,tol,elim,alim);
        inw=abs(nw);
        nz=eml_plus(nz,inw,'int32','spill');
        nn=eml_minus(nn,inw,'int32','spill');
        if nn==ZERO||nw>=ZERO
            return
        end
        dfnu=fnu+double(nn)-1;
    end
    if az<rl
        if dfnu<=1


            [cy,nw]=cmlri(z,fnu,kode,nn,cy,tol);
            nz=cap_negative_nw(nw);
            return
        end
    elseif dfnu<=1||~(2*az<dfnu*dfnu)


        [cy,nw]=casyi(z,fnu,kode,nn,cy,rl,tol,elim,alim);
        nz=cap_negative_nw(nw);
        return
    end


    [cy,nw]=cuoik(z,fnu,kode,ONE,nn,cy,tol,elim,alim);
    if nw<ZERO
        nz=cap_negative_nw(nw);
        return
    end
    nz=eml_plus(nz,nw,'int32','spill');
    nn=eml_minus(nn,nw,'int32','spill');
    if nn==ZERO
        return
    end
    dfnu=fnu+double(nn)-1;
    if dfnu>fnul||az>fnul


        if dfnu>fnul+1
            nui=ZERO;
        else
            nui=eml_cast(fnul-dfnu+1,'int32','to zero','spill');
        end
        [cy,nlast,nw]=cbuni(z,fnu,kode,nn,cy,nui,fnul,tol,elim,alim);
        if nw<ZERO
            nz=cap_negative_nw(nw);
            return
        end
        nz=eml_plus(nz,nw,'int32','spill');
        if nlast==ZERO
            return
        end
        nn=nlast;
    end

    if az>rl



        cw=complex(zeros(2,1));
        [cw,nw]=cuoik(z,fnu,kode,TWO,TWO,cw,tol,elim,alim);
        if nw<ZERO
            nz=nn;
            for i=ONE:nn
                cy(i)=0;
            end
        elseif nw>ZERO
            nz=MINUSONE;
        else
            [cy,nw]=cwrsk(z,fnu,kode,nn,cy,cw,tol,elim,alim);
            nz=cap_negative_nw(nw);
        end
    else


        [cy,nw]=cmlri(z,fnu,kode,nn,cy,tol);
        nz=cap_negative_nw(nw);
    end



    function nz=cap_negative_nw(nw)
        MINUSTWO=cast(-2,'int32');
        MINUSONE=cast(-1,'int32');
        ZERO=cast(0,'int32');
        if nw<ZERO
            if nw==MINUSTWO
                nz=MINUSTWO;
            else
                nz=MINUSONE;
            end
        else
            nz=ZERO;
        end



        function[y,nlast,nz]=cbuni(z,fnu,kode,nin,y,nui,fnul,tol,elim,alim)











%#codegen

            n=eml_min(nin,numel(y));
            MINUSTWO=cast(-2,'int32');
            MINUSONE=cast(-1,'int32');
            ZERO=cast(0,'int32');
            ONE=cast(1,'int32');
            TWO=cast(2,'int32');
            THREE=cast(3,'int32');
            nz=ZERO;
            xx=real(z);
            yy=imag(z);
            ax=abs(xx)*1.7321;
            ay=abs(yy);
            iform=ONE;
            if ay>ax
                iform=TWO;
            end
            if nui==ZERO
                if iform==TWO



                    [y,nlast,nw]=cuni2(z,fnu,kode,n,y,fnul,tol,elim,alim);
                else


                    [y,nlast,nw]=cuni1(z,fnu,kode,n,y,fnul,tol,elim,alim);
                end
                if nw<ZERO
                    nz=MINUSONE;
                    if nw==MINUSTWO
                        nz=MINUSTWO;
                    end
                    return
                end
                nz=nw;
                return
            end
            fnui=double(nui);
            dfnu=fnu+double(n)-1;
            gnu=dfnu+fnui;
            cy=complex(zeros(2,1));
            if iform==TWO



                [cy,nlast,nw]=cuni2(z,gnu,kode,TWO,cy,fnul,tol,elim,alim);
            else


                [cy,nlast,nw]=cuni1(z,gnu,kode,TWO,cy,fnul,tol,elim,alim);
            end
            if nw<ZERO
                nz=MINUSONE;
                if nw==MINUSTWO
                    nz=MINUSTWO;
                end
                return
            end
            if nw~=ZERO
                nlast=n;
                return
            end
            ay=abs(cy(1));

            bry0=1000*realmin('double')/tol;
            bry1=1/bry0;
            bry=[bry0,bry1,bry1];
            iflag=TWO;
            ascle=bry1;
            ax=1;
            dscl=1;
            if ay>bry0
                if ay>=bry1
                    iflag=THREE;
                    ascle=bry(3);
                    ax=tol;
                    dscl=ax;
                end
            else
                iflag=ONE;
                ascle=bry0;
                ax=1/tol;
                dscl=ax;
            end
            ay=1/ax;
            dscr=ay;
            s1=cy(2)*dscl;
            s2=cy(1)*dscl;
            rz=2/z;
            for i=ONE:nui
                st=s2;
                s2=s2*rz;
                s2=s2*(dfnu+fnui);
                s2=s2+s1;
                s1=st;
                fnui=fnui-1;
                if~(iflag>=THREE)
                    st=s2*dscr;
                    if~(eml_max(abs(real(st)),abs(imag(st)))<=ascle)
                        iflag=eml_plus(iflag,ONE,'int32','spill');
                        ascle=bry(iflag);
                        s1=s1*dscr;
                        s2=st;
                        ax=ax*tol;
                        ay=1/ax;
                        dscl=ax;
                        dscr=ay;
                        s1=s1*dscl;
                        s2=s2*dscl;
                    end
                end
            end
            y(n)=s2*dscr;
            if n==ONE
                return
            end
            nl=eml_minus(n,ONE,'int32','spill');
            fnui=double(nl);
            k=nl;
            for I=ONE:nl
                st=s2;
                s2=s2*rz;
                s2=s2*(dfnu+fnui);
                s2=s2+s1;
                s1=st;
                st=s2*dscr;
                y(k)=st;
                fnui=fnui-1;
                k=eml_minus(k,ONE,'int32','spill');
                if~(iflag>=THREE)&&~(eml_max(abs(real(st)),abs(imag(st)))<=ascle)
                    iflag=eml_plus(iflag,ONE,'int32','spill');
                    ascle=bry(iflag);
                    s1=s1*dscr;
                    s2=st;
                    ax=ax*tol;
                    ay=1/ax;
                    dscl=ax;
                    dscr=ay;
                    s1=s1*dscl;
                    s2=s2*dscl;
                end
            end



            function[y,nz]=cwrsk(zr,fnu,kode,nin,y,cw,tol,elim,alim)











%#codegen

                n=eml_min(nin,numel(y));
                MINUSTWO=cast(-2,'int32');
                MINUSONE=cast(-1,'int32');
                ZERO=cast(0,'int32');
                TWO=cast(2,'int32');
                nz=ZERO;
                [cw,nw]=cbknu(zr,fnu,kode,TWO,cw,tol,elim,alim);
                if nw~=ZERO
                    nz=MINUSONE;
                    if nw==MINUSTWO
                        nz=MINUSTWO;
                    end
                    return
                end
                y=crati(zr,fnu,n,y,tol);


                if kode==1
                    cinu=complex(1);
                else
                    cinu=complex(cos(imag(zr)),sin(imag(zr)));
                end




                acw=abs(cw(2));
                ascle=1000*realmin('double')/tol;
                if acw>ascle
                    ascle=1/ascle;
                    if acw>=ascle
                        cscl=complex(tol);
                    else
                        cscl=complex(1);
                    end
                else
                    cscl=complex(1/tol);
                end
                c1=cw(1)*cscl;
                c2=cw(2)*cscl;
                st=y(1);


                ct=st*c1;
                ct=ct+c2;
                ct=ct*zr;
                act=abs(ct);
                rct=1/act;
                ct=conj(ct);
                ct=ct*rct;
                cinu=cinu*rct;
                cinu=cinu*ct;
                y(1)=cinu*cscl;
                if n>=TWO
                    for i=TWO:n
                        cinu=cinu*st;
                        st=y(i);
                        y(i)=cinu*cscl;
                    end
                end



                function cy=crati(z,fnu,nin,cy,tol)











%#codegen

                    n=eml_min(nin,numel(cy));
                    ZERO=cast(0,'int32');
                    ONE=cast(1,'int32');
                    TWO=cast(2,'int32');
                    if n<ONE
                        return
                    end
                    inu=eml_cast(fnu,'int32','to zero','spill');
                    idnu=eml_minus(eml_plus(inu,n,'int32','spill'),ONE,'int32','spill');
                    fdnu=double(idnu);
                    magz=eml_cast(abs(z),'int32','to zero','spill');
                    amagz=double(magz)+1;
                    fnup=eml_max(amagz,fdnu);
                    id=magz+ONE;
                    if idnu>id
                        id=ZERO;
                    else
                        id=eml_minus(id,idnu,'int32','spill');
                    end
                    k=ONE;
                    rz=complex(2/z);
                    t1=fnup*rz;
                    p2=-t1;
                    p1=complex(1);
                    t1=t1+rz;
                    ap2=abs(p2);
                    ap1=abs(p1);




                    arg=(ap2+ap2)/(ap1*tol);
                    test1=sqrt(arg);
                    test=test1;
                    rap1=1/ap1;
                    p1=p1*rap1;
                    p2=p2*rap1;
                    ap2=ap2*rap1;
                    itime=ONE;
                    while itime<=TWO
                        k=eml_plus(k,ONE,'int32','spill');
                        ap1=ap2;
                        pt=p2;
                        p2=t1*p2;
                        p2=p1-p2;
                        p1=pt;
                        t1=t1+rz;
                        ap2=abs(p2);
                        if~(ap1<=test)
                            if itime==ONE
                                ak=abs(t1)*0.5;
                                flam=ak+sqrt(ak*ak-1);
                                rho=eml_min(ap2/ap1,flam);
                                test=test1*sqrt(rho/(rho*rho-1));
                            end
                            itime=eml_plus(itime,ONE,'int32','spill');
                        end
                    end

                    kk=eml_plus(eml_plus(k,ONE,'int32','spill'),id,'int32','spill');
                    ak=double(kk);
                    dfnu=fnu+double(n)-1;
                    cdfnu=complex(dfnu);
                    t1=complex(ak);
                    p1=complex(1/ap2);
                    p2=complex(0);
                    for i=ONE:kk
                        pt=p1;
                        tmp=cdfnu+t1;
                        tmp=rz*tmp;
                        tmp=tmp*p1;
                        p1=tmp+p2;
                        p2=pt;
                        t1=t1-1;
                    end
                    if p1==0
                        p1(1)=complex(tol,tol);
                    end
                    cy(n)=p2/p1;
                    if n==ONE
                        return
                    end
                    k=eml_minus(n,ONE,'int32','spill');
                    ak=double(k);
                    t1(1)=ak;
                    cdfnu=fnu*rz;
                    for i=TWO:n
                        tmp=t1*rz;
                        tmp=tmp+cdfnu;
                        pt=tmp+cy(eml_plus(k,ONE,'int32','spill'));
                        if pt==0
                            pt(1)=complex(tol,tol);
                        end
                        cy(k)=1/pt;
                        t1=t1-1;
                        k=eml_minus(k,ONE,'int32','spill');
                    end



                    function[y,nlast,nz]=cuni1(z,fnu,kode,nin,y,fnul,tol,elim,alim)











%#codegen

                        n=eml_min(nin,numel(y));
                        MINUSONE=cast(-1,'int32');
                        ZERO=cast(0,'int32');
                        ONE=cast(1,'int32');
                        TWO=cast(2,'int32');
                        THREE=cast(3,'int32');
                        nz=ZERO;
                        nd=n;
                        nlast=ZERO;



                        cssr=[1/tol,1,tol];
                        csrr=[tol,1,1/tol];
                        bry1=1000*realmin('double')/tol;

                        fn=eml_max(fnu,1);
                        init=ZERO;
                        cwrk=complex(zeros(16,1));
                        [~,zeta1,zeta2,~,~,cwrk]=cunik(z,fn,ONE,ONE,tol,init,cwrk);
                        if kode==1
                            s1=zeta2-zeta1;
                        else
                            s1=z+zeta2;
                            s1=fn/s1;
                            s1=fn*s1;
                            s1=s1-zeta1;
                        end
                        rs1=real(s1);
                        if abs(rs1)>elim
                            if rs1>0
                                nz=MINUSONE;
                            else
                                nz=eml_cast(n,'int32','to zero','spill');
                                for i=1:n
                                    y(i)=0;
                                end
                            end
                            return
                        end
                        while true

                            iflag=ZERO;
                            nn=eml_min(TWO,nd);
                            goto_mw110=false;
                            for i=ONE:nn
                                fn=fnu+double(eml_minus(nd,i,'int32','spill'));
                                init=ZERO;
                                [phi,zeta1,zeta2,summ,~,cwrk]=cunik(z,fn,ONE,ZERO,tol,init,cwrk);
                                if kode==1
                                    s1=zeta2-zeta1;
                                else
                                    s1=z+zeta2;
                                    s1=fn/s1;
                                    s1=fn*s1;
                                    s1=s1-zeta1;
                                    s1=complex(real(s1),imag(s1)+imag(z));
                                end

                                rs1=real(s1);
                                if abs(rs1)>elim
                                    goto_mw110=true;
                                    break
                                end
                                if i==ONE
                                    iflag=TWO;
                                end
                                if abs(rs1)>=alim

                                    aphi=abs(phi);
                                    rs1=rs1+log(aphi);
                                    if abs(rs1)>elim
                                        goto_mw110=true;
                                        break
                                    end
                                    if i==ONE
                                        iflag=ONE;
                                    end
                                    if rs1>=0
                                        if i==ONE
                                            iflag=THREE;
                                        end
                                    end
                                end

                                s2=phi*summ;
                                c2m=exp(real(s1))*cssr(iflag);
                                tmp=complex(cos(imag(s1)),sin(imag(s1)));
                                s1=c2m*tmp;
                                s2=s2*s1;
                                if iflag==ONE
                                    nw=cuchk(s2,bry1,tol);
                                    if nw~=ZERO
                                        goto_mw110=true;
                                        break
                                    end
                                end

                                ndmi=eml_minus(nd,i,'int32','spill');
                                y(eml_plus(ndmi,ONE,'int32','spill'))=s2*csrr(iflag);
                            end
                            if~goto_mw110


                                break
                            end


                            if rs1>0
                                nz=MINUSONE;
                                return
                            end
                            y(nd)=0;
                            nz=eml_plus(nz,ONE,'int32','spill');
                            nd=eml_minus(nd,ONE,'int32','spill');
                            if nd==ZERO
                                return
                            end
                            [y,nuf]=cuoik(z,fnu,kode,ONE,nd,y,tol,elim,alim);
                            if nuf<ZERO
                                nz=MINUSONE;
                                return
                            end
                            nd=eml_minus(nd,nuf,'int32','spill');
                            nz=eml_plus(nz,nuf,'int32','spill');
                            if nd==ZERO
                                return
                            end
                            fn=fnu+double(nd)-1;
                            if~(fn>=fnul)
                                nlast=nd;
                                break
                            end
                        end




                        function[y,nlast,nz]=cuni2(z,fnu,kode,nin,y,fnul,tol,elim,alim)











%#codegen

                            n=eml_min(nin,numel(y));
                            MINUSONE=cast(-1,'int32');
                            ZERO=cast(0,'int32');
                            ONE=cast(1,'int32');
                            TWO=cast(2,'int32');
                            THREE=cast(3,'int32');
                            nz=ZERO;
                            nd=n;
                            nlast=ZERO;



                            cssr=[1/tol,1,tol];
                            csrr=[tol,1,1/tol];
                            bry1=1000*realmin('double')/tol;
                            yy=imag(z);

                            zn=complex(imag(z),-real(z));
                            zb=z;
                            cid=-1i;
                            ffnu=fix(fnu);
                            inu=eml_cast(ffnu,'int32','to zero','spill');
                            ang=0.5*(fnu-ffnu);
                            [cang,sang]=coder.internal.scalar.cospiAndSinpi(ang);
                            c2=complex(cang,sang);
                            zar=c2;
                            in=eml_minus(eml_plus(inu,n,'int32','spill'),ONE,'int32','spill');
                            in=mod4p1(in);
                            CIP=[1,1i,-1,-1i];
                            c2=c2*CIP(in);
                            if yy<=0
                                zn=complex(-real(zn),imag(zn));
                                zb=conj(zb);
                                cid=-cid;
                                c2=conj(c2);
                            end

                            fn=eml_max(fnu,1);
                            [~,~,zeta1,zeta2,~,~]=cunhj(zn,fn,ONE,tol);
                            if kode==ONE
                                s1=zeta2-zeta1;
                            else
                                s1=zb+zeta2;
                                s1=fnu/s1;
                                s1=fnu*s1;
                                s1=s1-zeta1;
                            end
                            rs1=real(s1);
                            if abs(rs1)>elim
                                if rs1>0
                                    nz=MINUSONE;
                                else
                                    nz=n;
                                    for i=ONE:n
                                        y(i)=0;
                                    end
                                end
                                return
                            end
                            while true
                                goto_mw120=false;
                                cy=complex(zeros(2,1));
                                iflag=ZERO;
                                nn=eml_min(TWO,nd);
                                for i=ONE:nn
                                    fn=fnu+double(eml_minus(nd,i,'int32','spill'));
                                    [phi,arg,zeta1,zeta2,asum,bsum]=cunhj(zn,fn,ZERO,tol);
                                    if kode==ONE
                                        s1=zeta2-zeta1;
                                    else
                                        s1=zb+zeta2;
                                        s1=fn/s1;
                                        s1=fn*s1;
                                        s1=s1-zeta1;
                                        s1=s1+abs(yy)*1i;
                                    end

                                    rs1=real(s1);
                                    if abs(rs1)>elim
                                        goto_mw120=true;
                                        break
                                    end
                                    if i==ONE
                                        iflag=TWO;
                                    end
                                    if abs(rs1)>=alim

                                        APHI=abs(phi);
                                        AARG=abs(arg);
                                        rs1=rs1+log(APHI)-0.25*log(AARG)-1.265512123484645396;
                                        if abs(rs1)>elim
                                            goto_mw120=true;
                                            break
                                        end
                                        if i==ONE
                                            iflag=ONE;
                                        end
                                        if rs1>=0
                                            if i==ONE
                                                iflag=THREE;
                                            end
                                        end
                                    end


                                    ai=cairy(arg,ZERO,TWO);
                                    dai=cairy(arg,ONE,TWO);
                                    s2=ai*asum;
                                    tmp=dai*bsum;
                                    s2=s2+tmp;
                                    s2=s2*phi;
                                    c2m=exp(real(s1))*cssr(iflag);
                                    tmp=complex(cos(imag(s1)),sin(imag(s1)));
                                    s1=c2m*tmp;
                                    s2=s2*s1;
                                    if iflag==ONE
                                        nw=cuchk(s2,bry1,tol);
                                        if nw~=ZERO
                                            goto_mw120=true;
                                            break
                                        end
                                    end
                                    if yy<=0
                                        s2=conj(s2);
                                    end
                                    j=eml_plus(eml_minus(nd,i,'int32','spill'),ONE,'int32','spill');
                                    s2=s2*c2;
                                    cy(i)=s2;
                                    y(j)=s2*csrr(iflag);
                                    c2=c2*cid;
                                end
                                if~goto_mw120
                                    return
                                end

                                if rs1>0
                                    nz=MINUSONE;
                                    return
                                end

                                y(nd)=0;
                                nz=eml_plus(nz,ONE,'int32','spill');
                                nd=eml_minus(nd,ONE,'int32','spill');
                                if nd==ZERO
                                    return
                                end
                                [y,nuf]=cuoik(z,fnu,kode,ONE,nd,y,tol,elim,alim);
                                if nuf<ZERO
                                    nz=MINUSONE;
                                    return
                                end
                                nd=eml_minus(nd,nuf,'int32','spill');
                                nz=eml_plus(nz,nuf,'int32','spill');
                                if nd==ZERO
                                    return
                                end
                                fn=fnu+double(nd)-1;
                                if fn<fnul
                                    nlast=nd;
                                    return
                                end
                                inundm1=eml_minus(eml_plus(inu,nd,'int32','spill'),...
                                ONE,'int32','spill');
                                in=mod4p1(inundm1);
                                c2=zar*CIP(in);
                                if yy<=0
                                    c2=conj(c2);
                                end
                            end



                            function y=mod4p1(x)
                                ONE=cast(1,'int32');
                                TWO=cast(2,'int32');
                                y=eml_minus(x,eml_lshift(eml_rshift(x,TWO),TWO),...
                                'int32','spill');
                                y=eml_plus(y,ONE,'int32','spill');


