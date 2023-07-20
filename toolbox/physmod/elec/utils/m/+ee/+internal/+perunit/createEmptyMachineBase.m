function[base]=createEmptyMachineBase()%#codegen




    coder.allowpcode('plain');


    base=ee.internal.perunit.createEmptyBase();


    base.nPolePairs=nan;
    base.wMechanical=nan;
    base.torque=nan;
end

