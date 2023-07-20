function sl_postprocess(h)


















    ft={
    {sprintf('sh_legacy_lib/hydraulic_machines/Variable-Displacement\nHydraulic Machine'),sprintf('sh_legacy_lib/Hydraulic Machines/Variable-Displacement\nHydraulic Machine')}...
    ,{sprintf('sh_legacy_lib/hydraulic_machines/Variable-Displacement\nHydraulic Machine\n(External\nEfficiencies)'),sprintf('sh_legacy_lib/Hydraulic Machines/Variable-Displacement\nHydraulic Machine\n(External\nEfficiencies)')}...
    ,{sprintf('sh_legacy_lib/hydraulic_cylinders/Pneumo-Hydraulic\nActuator'),sprintf('sh_legacy_lib/Hydraulic Cylinders/Pneumo-Hydraulic\nActuator')}...
    };


    set_param(h,'ForwardingTable',ft);


    validateNames=nesl_private('nesl_validatenames');
    validateNames(h);





end
