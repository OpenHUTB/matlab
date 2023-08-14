function[saturateMode]=getBlockInfo(~,hC)





    slbh=hC.SimulinkHandle;

    sat=get_param(slbh,'saturateOnIntegerOverflow');

    if strcmp(sat,'on')
        saturateMode='Saturate';
    else
        saturateMode='Wrap';
    end

    pirelab.getTypeInfoAsFi(hC.SLOutputSignals(1).Type,'nearest',saturateMode);
