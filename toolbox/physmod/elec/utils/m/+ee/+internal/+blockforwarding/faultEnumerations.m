function out=faultEnumerations(in)










    out=in;





    if~isempty(in.getValue('fault_action'))
        fault_action=in.getValue('fault_action');
        fault_action=strrep(fault_action,'ee.enum.faults.faultAction','simscape.enum.assert.action');
        out=out.setValue('fault_action',fault_action);
    end






    if~isempty(in.getValue('enable_fault'))
        enable_fault=in.getValue('enable_fault');
        if strcmp(enable_fault,'ee.enum.faults.faultEnable.yes')
            enable_fault='simscape.enum.onoff.on';
        elseif strcmp(enable_fault,'ee.enum.faults.faultEnable.no')
            enable_fault='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_fault',enable_fault);
    end

    if~isempty(in.getValue('enable_faults'))
        enable_faults=in.getValue('enable_faults');
        if strcmp(enable_faults,'ee.enum.faults.faultEnable.yes')
            enable_faults='simscape.enum.onoff.on';
        elseif strcmp(enable_faults,'ee.enum.faults.faultEnable.no')
            enable_faults='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_faults',enable_faults);
    end

    if~isempty(in.getValue('enable_temporal_fault'))
        enable_temporal_fault=in.getValue('enable_temporal_fault');
        if strcmp(enable_temporal_fault,'ee.enum.faults.faultEnable.yes')
            enable_temporal_fault='simscape.enum.onoff.on';
        elseif strcmp(enable_temporal_fault,'ee.enum.faults.faultEnable.no')
            enable_temporal_fault='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_temporal_fault',enable_temporal_fault);
    end

    if~isempty(in.getValue('enable_behavioral_fault'))
        enable_behavioral_fault=in.getValue('enable_behavioral_fault');
        if strcmp(enable_behavioral_fault,'ee.enum.faults.faultEnable.yes')
            enable_behavioral_fault='simscape.enum.onoff.on';
        elseif strcmp(enable_behavioral_fault,'ee.enum.faults.faultEnable.no')
            enable_behavioral_fault='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_behavioral_fault',enable_behavioral_fault);
    end

    if~isempty(in.getValue('enable_fault_armature'))
        enable_fault_armature=in.getValue('enable_fault_armature');
        if strcmp(enable_fault_armature,'ee.enum.faults.faultEnable.yes')
            enable_fault_armature='simscape.enum.onoff.on';
        elseif strcmp(enable_fault_armature,'ee.enum.faults.faultEnable.no')
            enable_fault_armature='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_fault_armature',enable_fault_armature);
    end

    if~isempty(in.getValue('enable_fault_field'))
        enable_fault_field=in.getValue('enable_fault_field');
        if strcmp(enable_fault_field,'ee.enum.faults.faultEnable.yes')
            enable_fault_field='simscape.enum.onoff.on';
        elseif strcmp(enable_fault_field,'ee.enum.faults.faultEnable.no')
            enable_fault_field='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_fault_field',enable_fault_field);
    end

    if~isempty(in.getValue('enable_fault_series_field'))
        enable_fault_series_field=in.getValue('enable_fault_series_field');
        if strcmp(enable_fault_series_field,'ee.enum.faults.faultEnable.yes')
            enable_fault_series_field='simscape.enum.onoff.on';
        elseif strcmp(enable_fault_series_field,'ee.enum.faults.faultEnable.no')
            enable_fault_series_field='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_fault_series_field',enable_fault_series_field);
    end

    if~isempty(in.getValue('enable_fault_shunt_field'))
        enable_fault_shunt_field=in.getValue('enable_fault_shunt_field');
        if strcmp(enable_fault_shunt_field,'ee.enum.faults.faultEnable.yes')
            enable_fault_shunt_field='simscape.enum.onoff.on';
        elseif strcmp(enable_fault_shunt_field,'ee.enum.faults.faultEnable.no')
            enable_fault_shunt_field='simscape.enum.onoff.off';
        end
        out=out.setValue('enable_fault_shunt_field',enable_fault_shunt_field);
    end

end
