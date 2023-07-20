function item=getStringFormat(h)



    item=[];
    idx=1;

    item(idx).tlc_option_name='GenerateASAP2';
    item(idx).make_var_name='GENERATE_ASAP2';
    item(idx).prop_name='GenerateASAP2';
    idx=idx+1;

    item(idx).tlc_option_name='ExtMode';
    item(idx).make_var_name='EXT_MODE';
    item(idx).prop_name='ExtMode';
    idx=idx+1;

    item(idx).tlc_option_name='ExtModeStaticAlloc';
    item(idx).make_var_name='EXTMODE_STATIC_ALLOC';
    item(idx).prop_name='ExtModeStaticAlloc';
    idx=idx+1;

    item(idx).tlc_option_name='ExtModeStaticAllocSize';
    item(idx).make_var_name='EXTMODE_STATIC_ALLOC_SIZE';
    item(idx).prop_name='ExtModeStaticAllocSize';
    idx=idx+1;

    item(idx).tlc_option_name='ExtModeTransport';
    item(idx).make_var_name='EXTMODE_TRANSPORT';
    item(idx).prop_name='ExtModeTransport';
    idx=idx+1;

    item(idx).tlc_option_name='ExtModeTesting';
    item(idx).make_var_name='TMW_EXTMODE_TESTING';
    item(idx).prop_name='ExtModeTesting';
    idx=idx+1;

    item(idx).tlc_option_name='InlinedParameterPlacement';
    item(idx).make_var_name=[];
    item(idx).prop_name='InlinedParameterPlacement';
    idx=idx+1;

    item(idx).tlc_option_name='TargetOS';
    item(idx).make_var_name=[];
    item(idx).prop_name='TargetOS';
    idx=idx+1;

    item(idx).tlc_option_name='MultiInstanceErrorCode';
    item(idx).make_var_name=[];
    item(idx).prop_name='MultiInstanceErrorCode';
    idx=idx+1;

    item(idx).tlc_option_name='RateGroupingCode';
    item(idx).make_var_name=[];
    item(idx).prop_name='RateGroupingCode';
    idx=idx+1;

    item(idx).tlc_option_name='RTWCAPISignals';
    item(idx).make_var_name=[];
    item(idx).prop_name='RTWCAPISignals';
    idx=idx+1;

    item(idx).tlc_option_name='RTWCAPIParams';
    item(idx).make_var_name=[];
    item(idx).prop_name='RTWCAPIParams';
    idx=idx+1;

    item(idx).tlc_option_name='RootIOStructures';
    item(idx).make_var_name=[];
    item(idx).prop_name='RootIOFormat';
    item(idx).tlc_enum_in_num=true;
    idx=idx+1;

    item(idx).tlc_option_name='ERTCustomFileTemplate';
    item(idx).make_var_name=[];
    item(idx).prop_name='ERTCustomFileTemplate';
    idx=idx+1;


    if ismethod(h,'getExtensionStringFormat')
        item=h.getExtensionStringFormat(item,idx);
    end
