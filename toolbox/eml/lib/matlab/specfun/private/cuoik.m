function[y,nuf]=cuoik(z,fnu,kode,ikflg,nin,y,tol,elim,alim)











%#codegen

    coder.allowpcode('plain');
    n=eml_min(nin,numel(y));
    MINUSONE=cast(-1,'int32');
    ZERO=cast(0,'int32');
    ONE=cast(1,'int32');
    TWO=cast(2,'int32');

    nuf=ZERO;
    x=real(z);
    if x<0
        zr=-z;
    else
        zr=z;
    end
    zb=zr;
    yy=imag(zr);
    ax=abs(x)*1.7321;
    ay=abs(yy);
    if ay>ax
        iform=TWO;
    else
        iform=ONE;
    end
    if ikflg==ONE
        if fnu<1
            gnu=ones('like',fnu);
        else
            gnu=fnu;
        end
    else
        fnn=double(n);
        gnn=fnu+fnn-1;
        gnu=eml_max(gnn,fnn);
    end



    aarg=0;
    if iform==TWO
        if yy<=0
            an=complex(-imag(zr),-real(zr));
        else
            an=complex(imag(zr),-real(zr));
        end
        [phi,arg,zeta1,zeta2]=cunhj(an,gnu,ONE,tol);
        cz=zeta2-zeta1;
        aarg=abs(arg);
    else
        arg=complex(0);
        init=ZERO;
        [phi,zeta1,zeta2]=cunik(zr,gnu,ikflg,ONE,tol,init);
        cz=zeta2-zeta1;
    end
    if kode==TWO
        cz=cz-zb;
    end
    if ikflg==TWO
        cz=-cz;
    end
    aphi=abs(phi);
    rcz=real(cz);
    aic=1.265512123484645396;
    if rcz>=alim
        rcz=rcz+log(aphi);
        if iform==TWO
            rcz=rcz-0.25*log(aarg)-aic;
        end
        if rcz>elim
            nuf=MINUSONE;
        end

        return
    end
    if rcz>=-elim
        if rcz>-alim

            return
        end
        rcz=rcz+log(aphi);
        if iform==TWO
            rcz=rcz-0.25*log(aarg)-aic;
        end
        if rcz>-elim
            ASCLE=1000*realmin('double')/tol;
            tmp=log(phi);
            cz=cz+tmp;
            if iform==TWO
                tmp=log(arg);
                tmp=0.25*tmp;
                tmp=cz-tmp;
                cz=tmp-aic;
            end
            ax=exp(rcz)/tol;
            ay=imag(cz);
            cz=complex(ax*cos(ay),ax*sin(ay));
            nw=cuchk(cz,ASCLE,tol);
            if nw~=ONE

                return
            end
        end
    end
    for i=ONE:n
        y(i)=0;
    end
    nuf=n;
