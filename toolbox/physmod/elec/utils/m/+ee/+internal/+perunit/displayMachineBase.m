function displayMachineBase(b)%#codegen




    coder.allowpcode('plain');

    fprintf(getString(message('physmod:ee:library:comments:utils:perunit:displayMachineBase:sprintf_MachineBaseValues')));
    ee.internal.perunit.displayBase(b);
    ee.internal.displayField(b,'nPolePairs','1',getString(message('physmod:ee:library:comments:utils:perunit:displayMachineBase:sprintf_NumberOfPolePairs')));
    ee.internal.displayField(b,'wMechanical','rad/s',getString(message('physmod:ee:library:comments:utils:perunit:displayMachineBase:sprintf_MechanicalAngularSpeed')));
    ee.internal.displayField(b,'torque','N*m',getString(message('physmod:ee:library:comments:utils:perunit:displayMachineBase:sprintf_Torque')));
end

