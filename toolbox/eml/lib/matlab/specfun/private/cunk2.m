function[Y,NZ]=cunk2(Z,FNU,KODE,MR,TOL,ELIM,ALIM)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE,MR,TOL,ELIM,ALIM);

    Y=complex(0);
    ZERO=int32(0);
    MINUSONE=int32(-1);
    ONE=int32(1);
    TWO=int32(2);
    THREE=int32(3);
    FOUR=int32(4);
    KDFLG=ONE;
    NZ=ZERO;


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
    YY=imag(ZR);
    ZN=-ZR;
    ZN=1i*ZN;
    ZB=ZR;

    INU=eml_cast(FNU,'int32','to zero','spill');
    FNF=FNU-double(INU);
    HPI=pi/2;
    ANG=-HPI*FNF;
    SAR=sin(ANG);
    CAR=cos(ANG);
    C2=HPI*complex(SAR,-CAR);
    KK=mod(INU,FOUR)+1;
    CIP=[1,-1i,-1,1i];
    CR1=complex(1,sqrt(3));
    CS=CR1*C2;
    CS=CS*CIP(KK);
    if YY<0
        ZN=-ZN;
        ZN=conj(ZN);
        ZB=conj(ZB);
    end



    IFLAG=ZERO;
    KFLAG=ZERO;
    CY=complex(zeros(2,1));
    AIC=1.26551212348464539;
    CR2=complex(-0.5,-sqrt(0.75));
    FN=FNU+0;
    [PHI,ARG,ZETA1,ZETA2,ASUM,BSUM]=cunhj(ZN,FN,0,TOL);
    if KODE==1
        S1=ZETA1-ZETA2;
    else
        S1=ZB+ZETA2;
        S1=FN/S1;
        S1=FN*S1;
        S1=ZETA1-S1;
    end

    RS1=real(S1);
    goto60=abs(RS1)>ELIM;
    if~goto60
        if KDFLG==1
            KFLAG=TWO;
        end
        if abs(RS1)>=ALIM

            APHI=abs(PHI);
            AARG=abs(ARG);
            RS1=RS1+log(APHI)-0.25*log(AARG)-AIC;
            goto60=abs(RS1)>ELIM;
            if~goto60
                if KDFLG==1
                    KFLAG=ONE;
                end
                if RS1>=0
                    if KDFLG==1
                        KFLAG=THREE;
                    end
                end
            end
        end
        if~goto60


            C2=ARG*CR2;
            AI=cairy(C2,0,2);
            DAI=cairy(C2,1,2);
            tmp=AI*ASUM;
            S2=CR2*DAI;
            S2=S2*BSUM;
            S2=S2+tmp;
            tmp=CS*PHI;
            S2=tmp*S2;
            C2M=exp(real(S1))*CSSr(KFLAG);
            S1=complex(C2M*sin(imag(S1)),C2M*cos(imag(S1)));
            S2=S2*S1;
            if KFLAG==1
                NW=cuchk(S2,BRY(1),TOL);
                goto60=NW==0;
            end
            if~goto60
                if YY<=0
                    S2=conj(S2);
                end
                CY(KDFLG)=S2;
                Y=S2*CSRr(KFLAG);
            end
        end
    end
    if goto60
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
    [PHID,ARGD,ZETA1D,ZETA2D,~,~]=cunhj(ZN,FN,IPARD,TOL);
    if KODE==1
        S1=ZETA1D-ZETA2D;
    else
        S1=ZB+ZETA2D;
        S1=FN/S1;
        S1=FN*S1;
        S1=ZETA1D-S1;
    end
    RS1=real(S1);
    ABSRS1=abs(RS1);
    goto100=ABSRS1<ALIM&&ABSRS1<=ELIM;
    if~goto100

        RS1=RS1+log(abs(PHID))-0.25*log(abs(ARGD))-AIC;
        goto100=abs(RS1)<ELIM;
    end
    if~goto100
        if RS1>0
            NZ=MINUSONE;
        elseif X<0

            NZ=MINUSONE;
        else
            NZ=ONE;
            for k=1:ONE
                Y(k)=0;
            end
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
    if YY<=0
        CSGN=conj(CSGN);
    end

    INU=eml_cast(FNU,'int32','to zero','spill');
    FNF=FNU-double(INU);
    IFN=INU;
    ANG=FNF*SGN;
    if rem(IFN,TWO)==ONE
        CSPN=complex(-sin(ANG),-cos(ANG));
    else
        CSPN=complex(sin(ANG),cos(ANG));
    end




    CS=complex(CAR,-SAR)*CSGN;
    IN=mod(IFN,FOUR)+1;
    C2=CIP(IN);
    tmp=conj(C2);
    CS=CS*tmp;
    ASC=BRY(1);
    IUF=ZERO;
    KDFLG=ONE;
    FN=FNU+0;


    PHID=PHI;
    ARGD=ARG;
    ZETA1D=ZETA1;
    ZETA2D=ZETA2;
    ASUMD=ASUM;
    BSUMD=BSUM;

    if KODE==1
        S1=ZETA2D-ZETA1D;
    else
        S1=ZB+ZETA2D;
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
        if KDFLG==1
            IFLAG=TWO;
        end
        if~(abs(RS1)<ALIM)

            RS1=RS1+log(abs(PHID))-0.25*log(abs(ARGD))-AIC;
            if abs(RS1)>ELIM
                if RS1>0
                    NZ=MINUSONE;
                    return
                end
                S2=complex(0);
                goto210=false;
            elseif KDFLG==1
                if RS1<0
                    IFLAG=ONE;
                else
                    IFLAG=THREE;
                end
            end
        end
        if goto210

            AI=cairy(ARGD,0,2);
            DAI=cairy(ARGD,1,2);
            tmp=AI*ASUMD;
            S2=DAI*BSUMD;
            S2=S2+tmp;
            S2=PHID*S2;
            S2=CS*S2;
            C2M=exp(real(S1))*CSSr(IFLAG);
            tmp=complex(sin(imag(S1)),cos(imag(S1)));
            S1=C2M*tmp;
            S2=S2*S1;
            if IFLAG==1
                NW=cuchk(S2,BRY(1),TOL);
                if NW~=0
                    S2=complex(0);
                end
            end
        end
    end

    if YY<=0
        S2=conj(S2);
    end
    S2=S2*CSRr(IFLAG);

    S1=Y;
    if KODE~=1
        [S1,S2,~,NW]=cs1s2(ZR,S1,S2,ASC,ALIM,IUF);
        NZ=NZ+NW;
    end
    Y=S1*CSPN+S2;
