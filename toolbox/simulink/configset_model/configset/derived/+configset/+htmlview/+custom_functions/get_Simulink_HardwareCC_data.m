
function[params,groups,FC]=get_Simulink_HardwareCC_data(cs)

    compStatus=0;
    params={};


    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerChar');
        params{end+1}={0,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerShort');
        params{end+1}={1,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerInt');
        params{end+1}={2,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerLong');
        params{end+1}={3,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerLongLong');
        params{end+1}={4,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerFloat');
        params{end+1}={5,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerDouble');
        params{end+1}={6,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerPointer');
        params{end+1}={7,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerSizeT');
        params{end+1}={8,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdBitPerPtrDiffT');
        params{end+1}={9,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdLargestAtomicInteger');
        params{end+1}={10,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdLargestAtomicFloat');
        params{end+1}={11,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdIntDivRoundTo');
        params{end+1}={12,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdEndianess');
        params{end+1}={13,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdWordSize');
        params{end+1}={14,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdShiftRightIntArith');
        params{end+1}={15,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdLongLongMode');
        params{end+1}={16,{'st',p_st}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HWDevice(cs,'ProdHWDeviceType',0);
        p_tooltip=configset.internal.custom.prodHWDeviceType_TT(cs,'ProdHWDeviceType');
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        w_tooltip=configset.internal.custom.prodHWDeviceType_TT(cs,'ProdHWDeviceType_Vendor');
        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.HWDeviceVendor(cs,'ProdHWDeviceType_Vendor'));
        p_widgets{1}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options}};

        w_value=p_WidgetValues{2};
        w_tooltip=configset.internal.custom.prodHWDeviceType_TT(cs,'ProdHWDeviceType_Type');
        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.HWDeviceType(cs,'ProdHWDeviceType_Type'));
        w_st=configset.internal.custom.HWDeviceTypeStatus(cs,'ProdHWDeviceType_Type');
        p_widgets{2}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options},{'st',w_st}};
        params{end+1}={17,{'tooltip',p_tooltip},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerChar');
        params{end+1}={18,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerShort');
        params{end+1}={19,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerInt');
        params{end+1}={20,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerLong');
        params{end+1}={21,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerLongLong');
        params{end+1}={22,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerFloat');
        params{end+1}={23,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerDouble');
        params{end+1}={24,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerPointer');
        params{end+1}={25,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerSizeT');
        params{end+1}={26,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetBitPerPtrDiffT');
        params{end+1}={27,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetLargestAtomicInteger');
        params{end+1}={28,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetLargestAtomicFloat');
        params{end+1}={29,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetShiftRightIntArith');
        params{end+1}={30,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetLongLongMode');
        params{end+1}={31,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetIntDivRoundTo');
        params{end+1}={32,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetEndianess');
        params{end+1}={33,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'TargetWordSize');
        params{end+1}={34,{'st',p_st}};
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.HWDevice(cs,'TargetHWDeviceType',0);
        p_tooltip=configset.internal.custom.targetHWDeviceType_TT(cs,'TargetHWDeviceType');
        p_widgets=cell(1,2);

        w_value=p_WidgetValues{1};
        w_tooltip=configset.internal.custom.targetHWDeviceType_TT(cs,'TargetDeviceVendor');
        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.HWDeviceVendor(cs,'TargetDeviceVendor'));
        p_widgets{1}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options}};

        w_value=p_WidgetValues{2};
        w_tooltip=configset.internal.custom.targetHWDeviceType_TT(cs,'TargetDeviceType');
        w_options=configset.internal.util.convertToOptions(configset.internal.customwidget.HWDeviceType(cs,'TargetDeviceType'));
        p_widgets{2}={{'value',w_value},{'tooltip',w_tooltip},{'options',w_options}};
        params{end+1}={38,{'tooltip',p_tooltip},{'widgets',p_widgets}};
    end



    if compStatus<3
        p_WidgetValues=configset.internal.customwidget.targetUnknownValue(cs,'TargetUnknown',0);
        p_widgets=cell(1,1);

        w_value=p_WidgetValues{1};
        p_widgets{1}={{'value',w_value}};
        params{end+1}={39,{'widgets',p_widgets}};
    end



    if compStatus<3
        p_st=configset.internal.custom.HW_Status(cs,'ProdEqTarget');
        params{end+1}={40,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.isSLCAndECInstalledAndHardwareBoardNotNone(cs,'UseEmbeddedCoderFeatures');
        params{end+1}={41,{'st',p_st}};
    end



    if compStatus<3
        p_st=configset.internal.custom.isSLCInstalledAndHardwareBoardNotNone(cs,'UseSimulinkCoderFeatures');
        params{end+1}={42,{'st',p_st}};
    end



    if compStatus<3
        p_widgets=cell(1,1);

        w_st=codertarget.internal.isUseSoCFeaturesWidgetVisible(cs,'HardwareBoardFeatureSet');
        p_widgets{1}={{'st',w_st}};
        params{end+1}={43,{'widgets',p_widgets}};
    end


    groups={};






































    g_schema=configset.layout.custom.getTargetHardwareDialogSchema(cs,'web');
    groups{end+1}={'RunOnTargetHardware',{'schema',g_schema}};







