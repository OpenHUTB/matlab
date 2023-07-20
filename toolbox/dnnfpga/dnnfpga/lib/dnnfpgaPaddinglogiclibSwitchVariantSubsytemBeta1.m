function dnnfpgaPaddinglogiclibSwitchVariantSubsytemBeta1(gcb,threadNumLimit)



    simulationStatus=get_param(bdroot,'SimulationStatus');
    if(strcmpi(simulationStatus,'initializing'))
        return;
    end

    if(isempty(threadNumLimit))
        return;
    end

    vssBlk=gcb;
    if threadNumLimit>3
        newVariant='Variant';
    else
        newVariant='Variant1';
    end
    if(~isequal(get_param(vssBlk,'LabelModeActiveChoice'),newVariant))
        set_param(vssBlk,'LabelModeActiveChoice',newVariant);
    end

end
