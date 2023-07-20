function[ret,err]=gaugeAeroValidateScaleColors(dlgSrc)





    ret=true;
    err='';

    scChannel='/hmi_scalecolors_controller_/';
    numScales=numel(dlgSrc.ScaleColors);
    for idx=1:numScales
        prop=dlgSrc.ScaleColors(idx);


        invIdx={};
        if isempty(prop.Min)||~isreal(prop.Min)||~isfinite(prop.Min)
            invIdx{1}={idx,1};
        elseif isempty(prop.Max)||~isreal(prop.Max)||~isfinite(prop.Max)
            invIdx{1}={idx,2};
        end
        if~isempty(invIdx)
            ret=false;
            err=DAStudio.message('SimulinkHMI:dialogs:NonNumberScaleColorLimitsError');
            message.publish(...
            [scChannel,'showInvalidScaleColorLimits'],...
            {invIdx,err});
        end


        if prop.Min>prop.Max
            ret=false;
            invIdx{1}={idx,1};
            invIdx{2}={idx,2};
            err=DAStudio.message('SimulinkHMI:dialogs:ScaleColorLimitsMinGreaterThanMax');
            message.publish(...
            [scChannel,'showInvalidScaleColorLimits'],...
            {invIdx,err});
        end
    end
end
