function[Y,NZ]=cunk1(Z,FNU,KODE,MR,TOL,ELIM,ALIM)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE,MR,TOL,ELIM,ALIM);

    Y=complex(0);
    ZERO=int32(0);
    MINUSONE=int32(-1);
    ONE=int32(1);
    TWO=int32(2);
    THREE=int32(3);
    KDFLG=ONE;
    NZ=ZERO;
    IFLAG=ZERO;
    CWRK1=complex(zeros(16,1));
    CWRK2=complex(zeros(16,1));
    CY=complex(zeros(2,1));


    CSSr=[1/TOL,1,TOL];
    CSRr=[TOL,1,1/TOL];
    BRY1=1000*realmin/TOL;
    BRY=[BRY1,1/BRY1,realmax];
    X=real(Z);
    if X<0
        ZR=-Z;
    else
        ZR=Z;
    end
    FN=FNU+0;
    INIT=ZERO;
    [PHI,ZETA1,ZETA2,SUM,INIT,CWRK1]=cunik(ZR,FN,TWO,ZERO,TOL,INIT,CWRK1);
    if KODE==1
        S1=ZETA1-ZETA2;
    else
        S1=ZR+ZETA2;
        S1=FN/S1;
        S1=FN*S1;
        S1=ZETA1-S1;
    end

    RS1=real(S1);
    goto60=abs(RS1)>ELIM;
    if~goto60
        KFLAG=TWO;
        if~(abs(RS1)<ALIM)

            RS1=RS1+log(abs(PHI));
            goto60=abs(RS1)>ELIM;
            if~goto60
                KFLAG=ONE;
                if~(RS1<0)
                    KFLAG=THREE;
                end
            end
        end
        if~goto60


            S2=PHI*SUM(1);
            C2M=exp(real(S1))*CSSr(KFLAG);
            S1=complex(C2M*sin(imag(S1)),C2M*cos(imag(S1)));
            S2=S2*S1;
            if KFLAG==1
                NW=cuchk(S2,BRY(1),TOL);
                goto60=NW==0;
            end
            if~goto60
                CY(KDFLG)=S2;
                Y(1)=S2*CSRr(KFLAG);
                KDFLG=TWO;
            end
        end
    end
    if KDFLG==ONE
        if RS1>0
            NZ=MINUSONE;
            return
        end
        if X<0

            NZ=MINUSONE;
            return
        end
        Y(1)=0;
        NZ=NZ+1;
    end


    FN=FNU+0;
    if MR~=0
        IPARD=ZERO;
    else
        IPARD=ONE;
    end
    INITD=ZERO;
    [PHID,ZETA1D,ZETA2D,SUMD,INITD,CWRK2]=...
    cunik(ZR,FN,TWO,IPARD,TOL,INITD,CWRK2);%#ok<ASGLU>
    if KODE==1
        S1=ZETA1D-ZETA2D;
    else
        S1=ZR+ZETA2D;
        S1=FN/S1;
        S1=FN*S1;
        S1=ZETA1D-S1;
    end
    RS1=real(S1);
    ABSRS1=abs(RS1);
    goto100=ABSRS1<ALIM&&ABSRS1<=ELIM;
    if~goto100

        RS1=RS1+log(abs(PHID));
        goto100=abs(RS1)<ELIM;
    end
    if~goto100
        if RS1>0
            NZ=MINUSONE;
        elseif X<0

            NZ=MINUSONE;
        else
            NZ=ONE;
            Y(1)=0;
        end
        return
    end

    S2=CY(2);
    if MR==0
        return
    end

    NZ=ZERO;
    FMR=double(MR);
    if FMR<0
        SGN=pi;
    else
        SGN=-pi;
    end

    CSGN=complex(0,double(SGN));

    INU=eml_cast(FNU,'int32','to zero','spill');
    FNF=FNU-double(INU);
    IFN=INU;
    ANG=double(FNF*SGN);
    if rem(IFN,TWO)==ONE
        CSPN=complex(-sin(ANG),-cos(ANG));
    else
        CSPN=complex(sin(ANG),cos(ANG));
    end
    ASC=BRY(1);
    IUF=ZERO;
    FN=FNU+0;


    [PHID,ZETA1D,ZETA2D,SUMD,INIT,CWRK1]=cunik(ZR,FN,ONE,ZERO,TOL,INIT,CWRK1);%#ok<ASGLU>

    if KODE==1
        S1=ZETA2D-ZETA1D;
    else
        S1=ZR+ZETA2D;
        S1=FN/S1;
        S1=FN*S1;
        S1=S1-ZETA1D;
    end

    RS1=real(S1);
    if abs(RS1)>ELIM
        if RS1>0
            NZ=MINUSONE;
            return
        end
        S2=complex(0);
    else
        goto210=true;
        IFLAG=TWO;
        if~(abs(RS1)<ALIM)

            RS1=RS1+log(abs(PHID));
            if abs(RS1)>ELIM
                if RS1>0
                    NZ=MINUSONE;
                    return
                end
                S2=complex(0);
                goto210=false;
            else
                if RS1<0
                    IFLAG=ONE;
                else
                    IFLAG=THREE;
                end
            end
        end
        if goto210

            S2=CSGN*PHID;
            S2=S2*SUMD;
            C2M=exp(real(S1))*CSSr(IFLAG);
            S1=complex(sin(imag(S1)),cos(imag(S1)));
            S1=C2M*S1;
            S2=S2*S1;
            if IFLAG==1
                NW=cuchk(S2,BRY(1),TOL);
                if NW~=0
                    S2=complex(0);
                end
            end
        end
    end

    S2=S2*CSRr(IFLAG);

    S1=Y;
    if KODE~=1
        [S1,S2,IUF,NW]=cs1s2(ZR,S1,S2,ASC,ALIM,IUF);%#ok<ASGLU>
        NZ=NZ+NW;
    end
    Y=S1*CSPN+S2;
