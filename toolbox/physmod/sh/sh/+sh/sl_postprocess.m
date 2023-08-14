function sl_postprocess(h)


















    ft={
    {'sh_lib/Accumulators/Gas-Charged Accumulator','sh_lib/Accumulators/Gas-Charged Accumulator','0.0','8.51','sh_internal.transformAccumulatorR2015a'}
    {'sh_lib/Accumulators/Spring-Loaded Accumulator','sh_lib/Accumulators/Spring-Loaded Accumulator','0.0','8.51','sh_internal.transformAccumulatorR2015a'}
    {'sh_lib/Hydraulic Utilities/Hydraulic Fluid','sh_lib/Hydraulic Utilities/Hydraulic Fluid','0.0','8.71','sh_internal.transformHydraulicUtilitiesR2016a'}
    {'sh_lib/Pumps and Motors/Fixed-Displacement Pump','sh_lib/Pumps and Motors/Fixed-Displacement Pump','0.00','8008000.1','sh_internal.transformFixedDispPumpR2016b'}
    {'sh_lib/Pumps and Motors/Fixed-Displacement Motor (External Efficiencies)','sh_lib/Pumps and Motors/Fixed-Displacement Motor','sh_internal.transformFixedDispMotorExtEffR2016b'}
    {'sh_lib/Pumps and Motors/Hydraulic Motor','sh_lib/Pumps and Motors/Fixed-Displacement Motor','sh_internal.transformFixedDispMotorR2016b'}
    {'sh_lib/Pumps and Motors/Variable-Displacement Pump','sh_lib/Pumps and Motors/Variable-Displacement Pump','0.00','8008000.1','sh_internal.transformVariableDispPumpR2016b'}
    {'sh_lib/Pumps and Motors/Variable-Displacement Motor','sh_lib/Pumps and Motors/Variable-Displacement Motor','0.00','8008000.1','sh_internal.transformVariableDispMotorR2016b'}
    };


    set_param(h,'ForwardingTable',ft);


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Accumulators/Gas-Charged Accumulator'),...
    '8.51','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Accumulators/Spring-Loaded Accumulator'),...
    '8.51','8009000.1'});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/3-Way Directional\nValve'),'0.0','8009000.1'});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Ball Valve with\nConical Seat'),...
    sprintf('sh_lib/Valves/Flow Control Valves/Ball Valve')});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Ball Valve'),'0.0','8009000.1'});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Low-Pressure Blocks/Constant Head Tank'),...
    '0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Low-Pressure Blocks/Variable Head Tank'),sprintf('sh_lib/Low-Pressure Blocks/Tank')});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Low-Pressure Blocks/Variable Head\nTwo-Arm Tank'),...
    sprintf('sh_lib/Low-Pressure Blocks/Tank')});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Low-Pressure Blocks/Variable Head\nThree-Arm Tank'),...
    sprintf('sh_lib/Low-Pressure Blocks/Tank')});



    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Fixed Orifice'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Fixed Orifice with\nFluid Inertia'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Orifice with\nVariable Area Round\nHoles'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Orifice with\nVariable Area Slot'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Variable Orifice'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Orifices/Variable Orifice\nBetween Round Holes'),'0.0','8009000.1'});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Local Hydraulic Resistances/Elbow'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Local Hydraulic Resistances/Gradual Area Change'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Local Hydraulic Resistances/Local Resistance'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Local Hydraulic Resistances/Sudden Area Change'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Local Hydraulic Resistances/T-junction'),'0.0','8009000.1'});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/2-Way Directional\nValve'),'0.0','8009000.1'});




    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve A'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve B'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve C'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve D'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve E'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve F'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve G'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve H'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/4-Way Directional\nValve K'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/6-Way Directional\nValve A'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Cartridge Valve\nInsert'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Cartridge Valve\nInsert with Conical\nSeat'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Check Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Hydraulically\nOperated Remote\nControl Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Pilot-Operated Check\nValve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Directional Valves/Shuttle Valve'),'0.0','8009000.1'});

    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Pressure Control\nValves/Pressure Compensator'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Pressure Control\nValves/Pressure Reducing\n3-Way Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Pressure Control\nValves/Pressure Reducing Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Pressure Control\nValves/Pressure Relief Valve'),'0.0','8009000.1'});



    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Counterbalance Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Flow Divider'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Flow Divider-Combiner'),'0.0','9000000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Gate Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Needle Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Poppet Valve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Pressure-Compensated\n3-Way Flow Control\nValve'),'0.0','8009000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Valves/Flow Control Valves/Pressure-Compensated\nFlow Control Valve'),'0.0','8009000.1'});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Double-Acting Hydraulic Cylinder'),...
    '0.0','9000000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Single-Acting Hydraulic Cylinder'),...
    '0.0','9000000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Double-Acting Pneumo-Hydraulic Actuator'),...
    '0.0','9000000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Double-Acting Rotary Actuator'),...
    '0.0','9000000.1'});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Single-Acting Rotary Actuator'),...
    '0.0','9000000.1'});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Pumps and Motors/Variable-Displacement\nHydraulic Machine'),...
    sprintf('sh_legacy_lib/hydraulic_machines/Variable-Displacement\nHydraulic Machine')});
    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Pumps and Motors/Variable-Displacement\nHydraulic Machine\n(External\nEfficiencies)'),...
    sprintf('sh_legacy_lib/hydraulic_machines/Variable-Displacement\nHydraulic Machine\n(External\nEfficiencies)')});


    simscape.internal.blockforwarding.registerBlockUpdates(h,...
    {sprintf('sh_lib/Hydraulic Cylinders/Pneumo-Hydraulic\nActuator'),...
    sprintf('sh_legacy_lib/hydraulic_cylinders/Pneumo-Hydraulic\nActuator')});


    validateNames=nesl_private('nesl_validatenames');
    validateNames(h);





end
