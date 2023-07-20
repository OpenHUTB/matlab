function thisBase=SinglePhaseMachineBase(SRated,VRated,FRated,nPolePairs)%#codegen




    coder.allowpcode('plain');

    thisBase=ee.internal.perunit.createEmptyBase();

    thisBase.SRated=SRated;
    thisBase.VRated=VRated;
    thisBase.FRated=FRated;


    thisBase.SPerPhase=thisBase.SRated;
    thisBase.PPerPhase=thisBase.SPerPhase;
    thisBase.QPerPhase=thisBase.SPerPhase;
    thisBase.V=thisBase.VRated;
    thisBase.v=thisBase.VRated*sqrt(2);
    thisBase.I=thisBase.SPerPhase./thisBase.V;
    thisBase.i=sqrt(2)*thisBase.I;
    thisBase.Z=thisBase.V^2./thisBase.SPerPhase;
    thisBase.R=thisBase.Z;
    thisBase.X=thisBase.Z;
    thisBase.Y=thisBase.SPerPhase./thisBase.V^2;
    thisBase.G=thisBase.Y;
    thisBase.B=thisBase.Y;
    thisBase.wElectrical=2*pi*thisBase.FRated;
    thisBase.L=thisBase.X./thisBase.wElectrical;
    thisBase.C=1./(thisBase.X*thisBase.wElectrical);
    thisBase.psi=thisBase.L*thisBase.i;
    thisBase.Psi=thisBase.psi./sqrt(2);

    thisBase.nPolePairs=nPolePairs;
    thisBase.wMechanical=thisBase.wElectrical./thisBase.nPolePairs;
    thisBase.torque=thisBase.SRated./thisBase.wMechanical;

end