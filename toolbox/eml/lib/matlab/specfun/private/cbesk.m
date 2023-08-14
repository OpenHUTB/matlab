function[CY,NZ,IERR]=cbesk(Z,FNU,KODE)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE);
    MINUSONE=int32(-1);
    ZERO=int32(0);
    ONE=int32(1);
    TWO=int32(2);
    THREE=int32(3);
    FOUR=int32(4);
    FIVE=int32(5);
    CY=zeros('like',Z);
    IERR=ZERO;
    NZ=ZERO;
    if Z==0||FNU<0||KODE<ONE||KODE>TWO
        IERR=ONE;
        return
    end
    NN=ONE;









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
    AZ=abs(Z);
    FN=FNU+0;

    AA=0.5/TOL;
    BB=double(intmax)*0.5;
    AA=eml_min(AA,BB);
    if(AZ>AA)||(FN>AA)
        IERR=FOUR;
    else
        AA=sqrt(AA);
        if AZ>AA
            IERR=THREE;
        end
        if FN>AA
            IERR=THREE;
        end
    end

    UFL=realmin*1000;
    if AZ<UFL
        NZ=ZERO;
        IERR=TWO;
        return
    end
    if FNU>FNUL

        MR=ZERO;
        if real(Z)<0
            MR=ONE;
            if imag(Z)<0
                MR=MINUSONE;
            end
        end
        [CY,NW]=cbunk(Z,FNU,KODE,MR,TOL,ELIM,ALIM);
        if NW<0
            if NW==-1
                NZ=ZERO;
                IERR=TWO;
                return
            end
            NZ=ZERO;
            IERR=FIVE;
            return
        end
        NZ=NZ+NW;
        return
    end
    if FN>2

        [CY,NUF]=cuoik(Z,FNU,KODE,TWO,ONE,CY,TOL,ELIM,ALIM);
        if NUF<0
            NZ=ZERO;
            IERR=TWO;
            return
        end
        NZ=NZ+NUF;


        if NUF>0
            if real(Z)<0
                NZ=ZERO;
                IERR=TWO;
            end
            return
        end
    elseif~(AZ>TOL)
        ARG=0.5*AZ;
        ALN=-FN*log(ARG);
        if ALN>ELIM
            NZ=ZERO;
            IERR=TWO;
            return
        end
    end

    if real(Z)<0



        if NZ~=0
            NZ=ZERO;
            IERR=TWO;
            return
        end
        if imag(Z)<0
            MR=MINUSONE;
        else
            MR=ONE;
        end

        [CY,NW]=cacon(Z,FNU,KODE,MR,CY,RL,FNUL,TOL,ELIM,ALIM);
        if NW<0
            if NW==-1
                NZ=ZERO;
                IERR=TWO;
                return
            end
            NZ=ZERO;
            IERR=FIVE;
            return
        end
        NZ=NW;
    else


        [CY,NW]=cbknu(Z,FNU,KODE,NN,CY,TOL,ELIM,ALIM);
        if NW<0
            if NW==-1
                NZ=ZERO;
                IERR=TWO;
                return
            end
            NZ=ZERO;
            IERR=FIVE;
            return
        end
        NZ=NW;
    end