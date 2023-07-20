function e=ElectricalConstants()%#codegen




    coder.allowpcode('plain')

    persistent ElectricalConstants
    if isempty(ElectricalConstants)
        ElectricalConstants=ee.internal.createEmptyElectricalConstants();
        ElectricalConstants.a=exp(1i*2*pi/3);
        ElectricalConstants.a2=ElectricalConstants.a^2;
        ElectricalConstants.C=[1,1,1;1,ElectricalConstants.a,ElectricalConstants.a2;1,ElectricalConstants.a2,ElectricalConstants.a]/3;
        ElectricalConstants.A=[1,1,1;1,ElectricalConstants.a2,ElectricalConstants.a;1,ElectricalConstants.a,ElectricalConstants.a2];
        ElectricalConstants.j=1i;
        ElectricalConstants.oneOverSqrt2=sqrt(1/2);
        ElectricalConstants.oneOverSqrt3=sqrt(1/3);
        ElectricalConstants.shift_3ph=2.*pi.*[0,-1/3,1/3];
        ElectricalConstants.sqrt2=sqrt(2);
        ElectricalConstants.sqrt2OverSqrt3=sqrt(2/3);
        ElectricalConstants.sqrt3=sqrt(3);
        ElectricalConstants.sqrt3OverSqrt2=sqrt(3/2);
        ElectricalConstants.twoPi=2*pi;
        ElectricalConstants.twoPiOver3=2*pi/3;
    end
    e=ElectricalConstants;

end
