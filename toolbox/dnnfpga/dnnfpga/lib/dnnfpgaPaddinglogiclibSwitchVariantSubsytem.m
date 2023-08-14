function dnnfpgaPaddinglogiclibSwitchVariantSubsytem(gcb,threadNumLimit)



    simulationStatus=get_param(bdroot,'SimulationStatus');
    if(strcmpi(simulationStatus,'initializing'))
        return;
    end

    if(isempty(threadNumLimit))
        return;
    end

    vssBlk=gcb;





    newVariant='Variant';
    if(~isequal(get_param(vssBlk,'LabelModeActiveChoice'),newVariant))
        set_param(vssBlk,'LabelModeActiveChoice',newVariant);
    end

end
