function out=batterySharedComponent(in)










    out=in;




    movedEnumerations={'prm_age','prm_age_OCV','prm_AH','prm_dir',...
    'prm_dyn','prm_fade','prm_R2'};
    for enumIdx=1:length(movedEnumerations)
        enumValue=in.getValue(movedEnumerations{enumIdx});
        if~isempty(enumValue)
            enumValue=strrep(enumValue,'ee.enum.batterybasic','simscape.enum.battery');
            enumValue=strrep(enumValue,'ee.enum.enable','simscape.enum.battery.enable');
            out=out.setValue(movedEnumerations{enumIdx},enumValue);
        end
    end
end


