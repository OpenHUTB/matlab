function flag=checkInlineConfigurations(this)




    flag=true;

    sys_name=this.m_sys;
    if strcmpi(hdlget_param(sys_name,'TargetLanguage'),'VHDL')
        if strcmpi(hdlget_param(sys_name,'InlineConfigurations'),'off')
            flag=false;
            message=DAStudio.message('HDLShared:hdlmodelchecker:InlineConfigurationsError');
            this.addCheck('warning',message,sys_name,0);
        end
    end
end
