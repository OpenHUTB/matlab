


function allowedProfileProps=getAllowedProfileProperties(mappingType)
    if strcmp(mappingType,'data transfer mapping')
        allowedProfileProps='';
    elseif strcmp(mappingType,'model parameter mapping')
        allowedProfileProps=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration','Calibration','getAllProps');
    else
        allowedProfileProps=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration','Measurement','getAllProps');
    end
end
