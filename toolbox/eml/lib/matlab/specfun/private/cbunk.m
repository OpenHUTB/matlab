function[Y,NZ]=cbunk(Z,FNU,KODE,MR,TOL,ELIM,ALIM)











%#codegen

    coder.allowpcode('plain');
    coder.internal.prefer_const(FNU,KODE,MR,TOL,ELIM,ALIM);

    AX=abs(real(Z))*1.7321;
    AY=abs(imag(Z));
    if AY>AX



        [Y,NZ]=cunk2(Z,FNU,KODE,MR,TOL,ELIM,ALIM);
    else


        [Y,NZ]=cunk1(Z,FNU,KODE,MR,TOL,ELIM,ALIM);
    end