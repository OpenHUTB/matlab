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

    item=setLinkStringFormat(idx,item);



    function item=setLinkStringFormat(i,item)

        item(i).tlc_option_name='exportIDEObj';
        item(i).make_var_name='EXPORT_OBJ';
        item(i).prop_name='exportIDEObj';

        i=i+1;
        item(i).tlc_option_name='ideObjName';
        item(i).make_var_name='IDE_OBJ';
        item(i).prop_name='ideObjName';

        i=i+1;
        item(i).tlc_option_name='ProfileGenCode';
        item(i).make_var_name='PROFILE_GEN_CODE';
        item(i).prop_name='ProfileGenCode';

        i=i+1;
        item(i).tlc_option_name='InlineDSPBlks';
        item(i).make_var_name='INLINE_DSPBLKS';
        item(i).prop_name='InlineDSPBlks';

        i=i+1;
        item(i).tlc_option_name='buildAction';
        item(i).make_var_name='BUILD_ACTION';
        item(i).prop_name='buildAction';

        i=i+1;
        item(i).tlc_option_name='compilerOptionsStr';
        item(i).make_var_name='COMPILER_OPTIONS_STR';
        item(i).prop_name='compilerOptionsStr';

        i=i+1;
        item(i).tlc_option_name='linkerOptionsStr';
        item(i).make_var_name='LINKER_OPTIONS_STR';
        item(i).prop_name='linkerOptionsStr';

        i=i+1;
        item(i).tlc_option_name='systemStackSize';
        item(i).make_var_name='SYSTEM_STACK_SIZE';
        item(i).prop_name='systemStackSize';

        i=i+1;
        item(i).tlc_option_name='overrunNotificationMethod';
        item(i).make_var_name='OVERRUN_NOTIFICATION_METHOD';
        item(i).prop_name='overrunNotificationMethod';

        i=i+1;
        item(i).tlc_option_name='overrunNotificationFcn';
        item(i).make_var_name='OVERRUN_NOTIFICATION_FCN';
        item(i).prop_name='overrunNotificationFcn';

        i=i+1;
        item(i).tlc_option_name='configurePIL';
        item(i).make_var_name='CONFIGUREPIL';
        item(i).prop_name='configurePIL';

        i=i+1;
        item(i).tlc_option_name='configPILBlockAction';
        item(i).make_var_name='CONFIGPILBLOCKACTION';
        item(i).prop_name='configPILBlockAction';

        i=i+1;
        item(i).tlc_option_name='GenerateASAP2';
        item(i).make_var_name='GENERATE_ASAP2';
        item(i).prop_name='GenerateASAP2';

