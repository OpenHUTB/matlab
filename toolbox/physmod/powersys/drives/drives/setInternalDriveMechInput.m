function[INp,OUTp]=setInternalDriveMechInput(DriveType,block)









    switch DriveType

    case{'AC1','AC2','AC3','AC4',}
        MachineType='/Induction machine';
        MachineInputTorque='Torque Tm';
        MachineInputSpeed='Speed w';
        BusSelectorTorque='Mechanical.Electromagnetic torque Te (N*m)';
        BusSelectorSpeed='Mechanical.Rotor speed (wm)';

    case 'AC5'
        MachineType='/Synchronous Machine SI Fundamental';
        MachineInputTorque='Mechanical power Pm';
        MachineInputSpeed='Speed w';
        BusSelectorTorque='Mechanical.Electromagnetic torque  Te (N*m)';
        BusSelectorSpeed='Mechanical.Rotor speed  wm (rad/s)';

    case{'AC6','AC7','AC8'}
        MachineType='/Permanent Magnet Synchronous Machine';
        MachineInputTorque='Torque Tm';
        MachineInputSpeed='Speed w';
        BusSelectorTorque='Electromagnetic torque Te (N*m)';
        BusSelectorSpeed='Rotor speed wm (rad/s)';
    case{'AC9'}
        MachineType='/SPIM';
        MachineInputTorque='Torque Tm';
        MachineInputSpeed='Speed w';
        BusSelectorTorque='Mechanical.Electromagnetic torque Te (N*m)';
        BusSelectorSpeed='Mechanical.Rotor speed (rad/s or pu)';

    case{'DC1','DC2','DC3','DC4','DC5','DC6','DC7'}
        MachineType='/DC Machine';
        MachineInputTorque='Torque TL';
        MachineInputSpeed='Speed w';
        BusSelectorTorque='Electrical torque Te (n m)';
        BusSelectorSpeed='Speed wm (rad/s)';

    end

    switch get_param(block,'MechanicalLoad')

    case 'Torque Tm'
        INp='Tm';
        OUTp='Wm';
        if~bdIsLibrary(bdroot(block))
            set_param([block,MachineType],'MechanicalLoad',MachineInputTorque);
            set_param([block,'/Output Bus Selector'],'OutputSignals',BusSelectorSpeed);
        end

    case 'Speed w'
        INp='Wm';
        OUTp='Te';
        set_param([block,MachineType],'MechanicalLoad',MachineInputSpeed);
        set_param([block,'/Output Bus Selector'],'OutputSignals',BusSelectorTorque);

    case 'Mechanical rotational port'
        INp='S';
        OUTp='';
        set_param([block,MachineType],'MechanicalLoad','Mechanical rotational port');

    end