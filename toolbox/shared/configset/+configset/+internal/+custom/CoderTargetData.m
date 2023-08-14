function out=CoderTargetData(cs,~,direction,~)


    if isa(cs,'CoderTarget.SettingsController')
        ct=cs;
    elseif isa(cs,'Simulink.ConfigSet')
        ct=cs.getComponent('Coder Target');
    end

    if direction==0
        out={ct.CoderTargetData};
    elseif direction==1
        out=ct.CoderTargetData;
    end


