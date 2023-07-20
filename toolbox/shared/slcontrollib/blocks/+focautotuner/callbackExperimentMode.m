function callbackExperimentMode(blk)






    IsSinestream=strcmpi(get_param(blk,'ExperimentMode'),slsvInternal('slsvGetEnStringFromCatalog','Slcontrol:onlinefre:rbtnElementSS'));

    maskObj=Simulink.Mask.get(blk);
    objectD=maskObj.getDialogControl('ExperimentDescription');

    if IsSinestream
        objectD.Prompt=getString(message('SLControllib:focautotuner:ttipExperimentDescriptionFOCSinestream'));
    else
        objectD.Prompt=getString(message('SLControllib:focautotuner:ttipExperimentDescriptionFOC'));
    end

end