function schema





    pk=schema.package('xregGui');



    if isempty(findtype('xregGui.labelcontrol.SizeModeType'))
        schema.EnumType('xregGui.labelcontrol.SizeModeType',{'relative','absolute'},[0,1]);
    end

    if isempty(findtype('xregGui.labelcontrol.BaselineOffsetZeroType'))
        schema.EnumType('xregGui.labelcontrol.BaselineOffsetZeroType',{'top','middle','bottom'},[1,2,3]);
    end

    if isempty(findtype('xregGui.auto/manual'))
        schema.EnumType('xregGui.auto/manual',{'manual','auto'},[0,1]);
    end

    if isempty(findtype('xregGui.horz/vert'))
        schema.EnumType('xregGui.horz/vert',{'horizontal','vertical'},[0,1]);
    end








    p=schema.prop(pk,'TestMode','bool');
    p.Visible='off';
    p=schema.prop(pk,'ShowDialogCallback','MATLAB array');
    p.Visible='off';
    p=schema.prop(pk,'ErrorDlgCallback','MATLAB array');
    p.Visible='off';
