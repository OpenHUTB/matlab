function flag=checkArchitectureName(this)





    flag=true;

    sys_name=this.m_sys;
    targetLanguage=hdlget_param(sys_name,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')
        archName=hdlget_param(sys_name,'VHDLArchitectureName');

        if~contains(lower(archName),'rtl')
            flag=false;
            message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_architecture_name_error',archName);
            this.addCheck('warning',message,sys_name,0);
        end
    end
end