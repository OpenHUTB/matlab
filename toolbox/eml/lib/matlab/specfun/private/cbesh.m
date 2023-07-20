function[CY,NZ,IERR]=cbesh(Z,FNU,KODE,M)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE,M);
    ZERO=int32(0);
    ONE=int32(1);
    TWO=int32(2);
    THREE=int32(3);
    FOUR=int32(4);
    FIVE=int32(5);
    HPI=pi/2;
    CY=zeros('like',Z);
    NZ=ZERO;
    if Z==0||FNU<0||KODE<ONE||KODE>TWO||M<ONE||M>TWO
        IERR=ONE;
        return
    end
    IERR=ZERO;















    TOL=eps;
    K1=int32(-1021);
    K2=int32(1023);
    R1M5=log10(2);
    K=eml_min(abs(K1),abs(K2));
    ELIM=2.303*(double(K)*R1M5-3);
    K1=int32(52);
    AA=R1M5*double(K1);
    DIG=eml_min(AA,18);
    AA=AA*2.303;
    ALIM=ELIM+eml_max(-AA,-41.45);
    FNUL=10+6*(DIG-3);
    RL=1.2*DIG+3;
    FN=FNU+0;
    MM=THREE-M-M;
    FMM=double(MM);
    ZN=Z*complex(0,-FMM);
    XN=real(ZN);
    YN=imag(ZN);
    AZ=abs(Z);

    AA=0.5/TOL;
    BB=double(intmax)*0.5;
    AA=eml_min(AA,BB);
    if(AZ>AA||FN>AA)
        IERR=FOUR;
    else
        AA=sqrt(AA);
        if(AZ>AA||FN>AA)
            IERR=THREE;
        end
    end

    UFL=realmin*1000;
    if AZ<UFL
        IERR=TWO;
        NZ=ZERO;
        return
    end
    if FNU<=FNUL
        if FN>2

            [CY,NUF]=cuoik(ZN,FNU,KODE,TWO,ONE,CY,TOL,ELIM,ALIM);
            if NUF<0
                IERR=TWO;
                NZ=ZERO;
                return
            end
            NZ=NZ+NUF;


            if NUF>0
                if XN<0
                    IERR=TWO;
                    NZ=ZERO;
                end
                return
            end
        elseif~(FN<=1||AZ>TOL)
            ARG=0.5*AZ;
            ALN=-FN*log(ARG);
            if ALN>ELIM
                IERR=TWO;
                NZ=ZERO;
                return
            end
        end

        if(XN<0)||(XN==0&&YN<0&&M==2)


            MR=-MM;

            [CY,NW]=cacon(ZN,FNU,KODE,MR,CY,RL,FNUL,TOL,ELIM,ALIM);
            if NW<0
                if NW==-1
                    IERR=TWO;
                    NZ=ZERO;
                else
                    NZ=ZERO;
                    IERR=FIVE;
                end
                return
            end
            NZ=NW;
        else


            [CY,NZ]=cbknu(ZN,FNU,KODE,ONE,CY,TOL,ELIM,ALIM);
        end
    else


        MR=ZERO;
        if~((XN>=0)&&(XN~=0||YN>=0||M~=2))
            MR=-MM;
            if XN==0&&YN<0
                ZN=-ZN;
            end
        end

        [CY,NW]=cbunk(ZN,FNU,KODE,MR,TOL,ELIM,ALIM);
        if NW<0
            if NW==-1
                IERR=TWO;
                NZ=ZERO;
            else
                NZ=ZERO;
                IERR=FIVE;
            end
            return
        end
        NZ=NZ+NW;
    end






    INU=eml_cast(FNU,'int32','to zero','spill');
    INUH=idivide(INU,2,'fix');
    IR=INU-2*INUH;

    if FMM<0
        SGN=0.5;
        RHPI=1/HPI;
    else
        SGN=-0.5;
        RHPI=-1/HPI;
    end
    ARG=(FNU-double(INU-IR))*SGN;
    [CPN,SPN]=coder.internal.scalar.cospiAndSinpi(ARG);
    CPN=RHPI*CPN;
    SPN=RHPI*SPN;
    CSGN=complex(-SPN,CPN);
    if bitand(INUH,ONE)==ONE
        CSGN=-CSGN;
    end

    RTOL=1/TOL;
    ASCLE=UFL*RTOL;
    ZN=CY;
    ATOL=1;
    if eml_max(abs(real(ZN)),abs(imag(ZN)))<=ASCLE
        ZN=ZN*RTOL;
        ATOL=TOL;
    end
    ZN=ZN*CSGN;
    CY=ZN*ATOL;
