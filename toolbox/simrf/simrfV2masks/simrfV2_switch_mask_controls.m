function simrfV2_switch_mask_controls(block,switchType)



    switch lower(switchType)
    case 'potentiometer'
        MaskNames=get_param(block,'MaskNames');
        idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),MaskNames,2);
        maskEns=get_param(block,'MaskEnables');
        maskVis=get_param(block,'MaskVisibilities');
        curvetype=get_param(block,'CurveType');
        if strcmpi(curvetype,'Linear')
            maskVis{idxMaskParams.PercentLog}='off';
            maskEns{idxMaskParams.PercentLog}='off';
            maskVis{idxMaskParams.PercentAnti}='off';
            maskEns{idxMaskParams.PercentAnti}='off';
        elseif strcmpi(curvetype,'Logarithmic')
            maskVis{idxMaskParams.PercentLog}='on';
            maskEns{idxMaskParams.PercentLog}='on';
            maskVis{idxMaskParams.PercentAnti}='off';
            maskEns{idxMaskParams.PercentAnti}='off';
        else
            maskVis{idxMaskParams.PercentLog}='off';
            maskEns{idxMaskParams.PercentLog}='off';
            maskVis{idxMaskParams.PercentAnti}='on';
            maskEns{idxMaskParams.PercentAnti}='on';
        end
        set_param(block,'MaskEnables',maskEns)
        set_param(block,'MaskVisibilities',maskVis)
        cstruct=struct('Linear','1','Logarithmic','2','Antilog','3');
        set_param([block,'/POTENTIOMETER_RF'],'CurveType',cstruct.(curvetype));
    case 'switch_chartype'
        MaskNames=get_param(block,'MaskNames');
        idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),MaskNames,2);
        maskEns=get_param(block,'MaskEnables');
        maskVis=get_param(block,'MaskVisibilities');
        if strcmpi(get_param(block,'CharType'),'Resistance')
            maskVis{idxMaskParams.Ron}='on';
            maskEns{idxMaskParams.Ron}='on';
            maskVis{idxMaskParams.Ron_unit}='on';
            maskEns{idxMaskParams.Ron_unit}='on';
            maskVis{idxMaskParams.Roff}='on';
            maskEns{idxMaskParams.Roff}='on';
            maskVis{idxMaskParams.Roff_unit}='on';
            maskEns{idxMaskParams.Roff_unit}='on';
            maskVis{idxMaskParams.Iloss}='off';
            maskEns{idxMaskParams.Iloss}='off';
            maskVis{idxMaskParams.Iiso}='off';
            maskEns{idxMaskParams.Iiso}='off';
            if strcmpi(get_param(block,'LoadType'),'Reflective')
                maskVis{idxMaskParams.Z0}='off';
                maskEns{idxMaskParams.Z0}='off';
                maskVis{idxMaskParams.Z0_unit}='off';
                maskEns{idxMaskParams.Z0_unit}='off';
            else
                maskVis{idxMaskParams.Z0}='on';
                maskEns{idxMaskParams.Z0}='on';
                maskVis{idxMaskParams.Z0_unit}='on';
                maskEns{idxMaskParams.Z0_unit}='on';
            end
        else
            maskVis{idxMaskParams.Ron}='off';
            maskEns{idxMaskParams.Ron}='off';
            maskVis{idxMaskParams.Ron_unit}='off';
            maskEns{idxMaskParams.Ron_unit}='off';
            maskVis{idxMaskParams.Roff}='off';
            maskEns{idxMaskParams.Roff}='off';
            maskVis{idxMaskParams.Roff_unit}='off';
            maskEns{idxMaskParams.Roff_unit}='off';
            maskVis{idxMaskParams.Iloss}='on';
            maskEns{idxMaskParams.Iloss}='on';
            maskVis{idxMaskParams.Iiso}='on';
            maskEns{idxMaskParams.Iiso}='on';
            maskVis{idxMaskParams.Z0}='on';
            maskEns{idxMaskParams.Z0}='on';
            maskVis{idxMaskParams.Z0_unit}='on';
            maskEns{idxMaskParams.Z0_unit}='on';
        end
        set_param(block,'MaskEnables',maskEns)
        set_param(block,'MaskVisibilities',maskVis)
    case 'switch_loadtype'
        MaskNames=get_param(block,'MaskNames');
        idxMaskParams=cell2struct(num2cell(1:length(MaskNames)),MaskNames,2);
        maskEns=get_param(block,'MaskEnables');
        maskVis=get_param(block,'MaskVisibilities');
        if strcmpi(get_param(block,'LoadType'),'Reflective')&&...
            strcmpi(get_param(block,'CharType'),'Resistance')
            maskVis{idxMaskParams.Z0}='off';
            maskEns{idxMaskParams.Z0}='off';
            maskVis{idxMaskParams.Z0_unit}='off';
            maskEns{idxMaskParams.Z0_unit}='off';
        else
            maskVis{idxMaskParams.Z0}='on';
            maskEns{idxMaskParams.Z0}='on';
            maskVis{idxMaskParams.Z0_unit}='on';
            maskEns{idxMaskParams.Z0_unit}='on';
        end
        set_param(block,'MaskEnables',maskEns)
        set_param(block,'MaskVisibilities',maskVis)
    end

end