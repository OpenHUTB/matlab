function schema







    mlock;

    pk=findpackage('hdlcoderprops');
    c=schema.class(pk,'FilterCommon',pk.findclass('AbstractProp'));

    p=schema.prop(c,'filter_fir_final_adder','HDLFinalAddersType');
    set(p,'SetFunction',@set_filter_fir_final_adder);

    schema.prop(c,'filter_multipliers','HDLMultipliersType');
    schema.prop(c,'multiplier_input_pipeline','mxArray');
    schema.prop(c,'multiplier_output_pipeline','mxArray');
    schema.prop(c,'adder_tree_pipeline','mxArray');

    schema.prop(c,'RateChangePort','bool');
    schema.prop(c,'filter_coeff_name','string');
    schema.prop(c,'filter_pipelined','bool');

    p=[...
    schema.prop(c,'filter_registered_input','bool');...
    schema.prop(c,'filter_registered_output','bool');...
    ];
    set(p,'FactoryValue',true);

    p=schema.prop(c,'filter_name','string');
    set(p,'FactoryValue','filter');

    p=schema.prop(c,'filter_input_name','string');
    set(p,'FactoryValue','filter_in');

    p=schema.prop(c,'filter_output_name','string');
    set(p,'FactoryValue','filter_out');

    p=schema.prop(c,'filter_fracdelay_name','string');
    set(p,'FactoryValue','filter_fd');

    p=schema.prop(c,'filter_scalewarnbits','int32');
    set(p,'FactoryValue',3);

    p=schema.prop(c,'userspecified_foldingfactor','int32');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'filter_nummultipliers','int32');
    set(p,'FactoryValue',-1);

    p=schema.prop(c,'filter_excess_latency','int32');
    set(p,'FactoryValue',0);

    schema.prop(c,'filter_reuseaccum','bool');
    schema.prop(c,'filter_serialsegment_inputs','mxArray');
    schema.prop(c,'filter_dalutpartition','mxArray');
    p=schema.prop(c,'filter_daradix','power2_scalar');
    set(p,'FactoryValue',2);
    schema.prop(c,'filter_coefficient_source','mxArray');
    schema.prop(c,'filter_storage_type','mxArray');

    p=schema.prop(c,'foldingfactor','mxArray');
    set(p,'FactoryValue',1);

    schema.prop(c,'filter_complex_inputs','bool');

    schema.prop(c,'filter_input_datatype','mxArray');
    p=schema.prop(c,'fracdelay_datatype','mxArray');
    set(p,'FactoryValue',[]);

    p=schema.prop(c,'filter_generate_ceout','bool');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'filter_generate_coeff_port','bool');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'filter_generate_biquad_scale_port','bool');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'filter_generate_datavalid_output','bool');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'filter_generate_multichannel','int32');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'RemoveResetFrom','FilterResetTypeEnum');
    set(p,'FactoryValue','None');

    p=schema.prop(c,'enable_fpga_workflow','bool');
    set(p,'FactoryValue',0);

    schema.prop(c,'fpga_workflow_parameters','mxArray');

    schema.prop(c,'entitynamelist','mxArray');
    schema.prop(c,'entitypathlist','mxArray');
    schema.prop(c,'entityportlist','mxArray');
    schema.prop(c,'entityarchlist','mxArray');

    schema.prop(c,'lasttopleveltargetlang','mxArray');
    schema.prop(c,'lasttoplevelname','mxArray');
    schema.prop(c,'lasttoplevelports','mxArray');
    schema.prop(c,'lasttoplevelportnames','mxArray');
    schema.prop(c,'lasttopleveldecls','mxArray');
    schema.prop(c,'lasttoplevelinstance','mxArray');
    schema.prop(c,'lasttopleveltimestamp','mxArray');


    p=schema.prop(c,'clockenableinputname','string');
    set(p,'FactoryValue','ce_in');



    p=schema.prop(c,'clockenableoutputvalidname','string');
    set(p,'FactoryValue','ce_out_valid');

    schema.prop(c,'filter_multiclock_portname','string');


    schema.prop(c,'filter_multiclock_enableportname','string');


    schema.prop(c,'filter_multiclock_resetportname','string');


    p=schema.prop(c,'requestedoptimslowering','bool');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'forcedlowering','int32');
    set(p,'FactoryValue',0);

    p=schema.prop(c,'filter_systemobject','mxArray');
    set(p,'FactoryValue',[]);


    function fffa=set_filter_fir_final_adder(this,fffa)

        if strncmpi(fffa,'pipelined',length(fffa))
            set(this,'filter_pipelined',true);
        end








