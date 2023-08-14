function thisBase=MachineBase(SRated,VRated,FRated,connection,nPolePairs)%#codegen




    coder.allowpcode('plain');

    thisBase=ee.internal.perunit.Base(SRated,VRated,FRated,connection,ee.internal.perunit.createEmptyMachineBase());

    thisBase.nPolePairs=nPolePairs;
    thisBase.wMechanical=thisBase.wElectrical./thisBase.nPolePairs;
    thisBase.torque=thisBase.SRated./thisBase.wMechanical;

end