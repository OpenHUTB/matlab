function[angles,GeomXYZ]=vdynthree2six(angleIn,GemoXYZIn,GroundZ,trackW,wheelB)%#codegen
    coder.allowpcode('plain')






    Zcg=mean(GroundZ);
    psi=atan(((GroundZ(1)-GroundZ(2))+(GroundZ(3)-GroundZ(4)))./trackW./2);
    theta=atan(((GroundZ(1)-GroundZ(3))+(GroundZ(2)-GroundZ(4)))./wheelB./2);
    angles=[psi;theta;angleIn(3)];
    GeomXYZ=[GemoXYZIn(1:2);-Zcg];