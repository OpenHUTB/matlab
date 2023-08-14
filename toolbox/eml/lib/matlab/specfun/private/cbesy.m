function[CY,NZ,IERR]=cbesy(Z,FNU,KODE)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE);
    ZERO=int32(0);
    ONE=int32(1);
    TWO=int32(2);
    if Z==0||FNU<0||KODE<ONE||KODE>TWO
        CY=complex(0);
        NZ=ZERO;
        IERR=ONE;
        return
    end
    HCI=complex(0,0.5);
    [CY,NZ1,IERR]=cbesh(Z,FNU,KODE,ONE);
    if IERR~=0&&IERR~=3
        NZ=ZERO;
        return
    end
    [CWRK,NZ2,IERR]=cbesh(Z,FNU,KODE,TWO);
    if IERR~=0&&IERR~=3
        NZ=ZERO;
        return
    end
    NZ=eml_min(NZ1,NZ2);
    if KODE~=2
        CY=CWRK-CY;
        CY=HCI*CY;
        return
    end
    TOL=eps;
    K1=int32(-1021);
    K2=int32(1023);
    K=eml_min(abs(K1),abs(K2));
    R1M5=log10(2);

    ELIM=2.303*(double(K)*R1M5-3);
    EX=complex(cos(real(Z)),sin(real(Z)));
    EY=0;
    TAY=abs(imag(Z)*2);
    if TAY<ELIM
        EY=exp(-TAY);
    end
    if imag(Z)<0
        C1=EX;
        C2=conj(EX);
        C2=C2*EY;
    else
        C1=EX*EY;
        C2=conj(EX);
    end
    NZ=ZERO;
    RTOL=1.0/TOL;
    ASCLE=realmin*(RTOL*1000);
    ZV=CWRK;
    ATOL=1;
    if eml_max(abs(real(ZV)),abs(imag(ZV)))<=ASCLE
        ZV=ZV*RTOL;
        ATOL=TOL;
    end
    ZV=ZV*C2;
    ZV=ZV*HCI;
    ZV=ZV*ATOL;
    ZU=CY;
    ATOL=1;
    if eml_max(abs(real(ZU)),abs(imag(ZU)))<=ASCLE
        ZU=ZU*RTOL;
        ATOL=TOL;
    end
    ZU=C1*ZU;
    ZU=ZU*HCI;
    ZU=ZU*ATOL;
    CY=ZV-ZU;
    if CY==0&&EY==0
        NZ=NZ+1;
    end

