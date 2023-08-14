function sdl_classic_input_derivatives(block,var_num)




    maskStr=get_param(block,'MaskValues');
    vis=get_param(block,'MaskVisibilities');
    if strcmp(maskStr{var_num},'Use input as is')
        set_param(block,'MaskVisibilities',[vis(1:var_num);{'off'};{'off'}]);
    else
        set_param(block,'MaskVisibilities',[vis(1:var_num);{'on'};{'on'}]);
    end
end
