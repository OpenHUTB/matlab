function hNewC=elaborate(this,hN,hC)


    slbh=hC.SimulinkHandle;
    [rndMode,ovMode,convMode]=getBlockModes(slbh);

    nfpOptions=getNFPImplParamInfo(this,hC);
    hNewC=pirelab.getDTCComp(hN,hC.PirInputSignals,hC.PirOutputSignals,...
    rndMode,ovMode,convMode,hC.Name,'',-1,nfpOptions);
end



function[rndMode,ovMode,convMode]=getBlockModes(slbh)
    rndMode=get_param(slbh,'RndMeth');

    sat=get_param(slbh,'DoSatur');
    if strcmp(sat,'on')
        ovMode='Saturate';
    else
        ovMode='Wrap';
    end

    convtype=get_param(slbh,'ConvertRealWorld');

    if strcmpi(convtype,'Real World Value (RWV)')
        convMode='RWV';
    else
        convMode='SI';
    end
end


