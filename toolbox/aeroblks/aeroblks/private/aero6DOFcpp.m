function aero6DOFcpp(blkhdl,sixDofData)






    data.handle=blkhdl;
    data.sixDofData=sixDofData;
    Simulink.SimulationStepper(bdroot).addSnapshotInterface(snapshotanim(data))
