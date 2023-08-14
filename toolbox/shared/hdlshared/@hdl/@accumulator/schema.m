function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'accumulator',parent);

    p=schema.prop(c,'sum_type','mxArray');
    p=schema.prop(c,'adder_mode','mxArray');
    p=schema.prop(c,'feedback_gain','mxArray');
    p=schema.prop(c,'feedback_gain_type','mxArray');
    p=schema.prop(c,'feedback_gain_mode','mxArray');
    p=schema.prop(c,'load','mxArray');
    p=schema.prop(c,'load_val','mxArray');
    p=schema.prop(c,'reg_enable_accumulation','mxArray');
    p=schema.prop(c,'willread_reg_input','mxArray');
    p=schema.prop(c,'use_default_emit','mxArray');


    p=schema.prop(c,'adder_output','mxArray');
    p=schema.prop(c,'reg_input','mxArray');
    p=schema.prop(c,'reg_output','mxArray');
    p=schema.prop(c,'gainoutidx','mxArray');
    p=schema.prop(c,'load_val_idx','mxArray');
    p=schema.prop(c,'addend1','mxArray');
    p=schema.prop(c,'addend2','mxArray');
    p=schema.prop(c,'num_copies','mxArray');
    p=schema.prop(c,'dtc_adder_output','mxArray');
    p=schema.prop(c,'adder_output_recast','mxArray');

    p=schema.prop(c,'accumulator_style','mxArray');
    p=schema.prop(c,'load_val_hdlconst','mxArray');

    p=schema.prop(c,'hN','mxArray');
    p.FactoryValue=[];

    p=schema.prop(c,'slrate','mxArray');
    p.FactoryValue=-1;

