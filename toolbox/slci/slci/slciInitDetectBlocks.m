function slciInitDetectBlocks()



    prmVal=get_param(gcbh,'OutDataTypeStr');

    if strcmp(prmVal,'boolean')
        setValue='boolean';
    else
        setValue='fixdt(0, 8)';
    end

    set_param([gcb,'/FixPt Relational Operator'],'OutDataTypeStr',setValue);

    set_param([gcb,'/','Delay Input1'],...
    'InputProcessing',get_param(gcbh,'InputProcessing'));

    name=get_param(gcbh,'ReferenceBlock');
    switch(name)
    case sprintf('slcilib/Simulink/Logic and Bit\nOperations/Detect Rise Positive')
        compblk='Positive';
    case sprintf('slcilib/Simulink/Logic and Bit\nOperations/Detect Rise Nonnegative')
        compblk='Nonnegative';
    case sprintf('slcilib/Simulink/Logic and Bit\nOperations/Detect Fall Negative')
        compblk='Negative';
    case sprintf('slcilib/Simulink/Logic and Bit\nOperations/Detect Fall Nonpositive')
        compblk='Nonpositive';
    otherwise
        return;
    end

    set_param([gcb,'/',compblk],'OutDataTypeStr',prmVal);
