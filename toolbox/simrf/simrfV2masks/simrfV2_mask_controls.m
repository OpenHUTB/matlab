function simrfV2_mask_controls(block,switchType)



    switch lower(switchType)
    case 'pa_chartype'
        MaskNames=get_param(block,'MaskNames');
        idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),MaskNames,2);
        maskEns=get_param(block,'MaskEnables');
        maskVis=get_param(block,'MaskVisibilities');
        characterizationType=get_param(block,'CharType');
        if strcmpi(characterizationType,'Coefficients')
            maskVis{idxMaskParams.Coefficients}='on';
            maskEns{idxMaskParams.Coefficients}='on';
            maskVis{idxMaskParams.PowerCurve}='off';
            maskEns{idxMaskParams.PowerCurve}='off';
        else
            maskVis{idxMaskParams.Coefficients}='off';
            maskEns{idxMaskParams.Coefficients}='off';
            maskVis{idxMaskParams.PowerCurve}='on';
            maskEns{idxMaskParams.PowerCurve}='on';
        end
        set_param(block,'MaskEnables',maskEns)
        set_param(block,'MaskVisibilities',maskVis)
    end

end