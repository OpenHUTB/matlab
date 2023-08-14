function AnalyticalParameterization(model,blockPath)







    modelWorkspace=get_param(model,'ModelWorkSpace');
    blockName=modelWorkspace.getVariable('newTestBlockName');


    loss_spec=get_param([model,'/',blockName],'loss_spec');

    if loss_spec=='1'
        set_param(blockPath,'MaskVisibilities',{'on';'on'});
    elseif loss_spec=='2'
        set_param(blockPath,'MaskVisibilities',{'off';'off'});
    elseif loss_spec=='3'
        set_param(blockPath,'MaskVisibilities',{'off';'off'});
    end

end