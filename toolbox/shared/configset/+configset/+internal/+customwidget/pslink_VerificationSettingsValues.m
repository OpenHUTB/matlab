function out=pslink_VerificationSettingsValues(cs,name,direction,widgetVals)




    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('Polyspace');
    else
        hObj=cs;
    end

    if direction==0
        val=hObj.get_param(name);
        out={val,'',''};
    elseif direction==1
        out=widgetVals{1};
    end


