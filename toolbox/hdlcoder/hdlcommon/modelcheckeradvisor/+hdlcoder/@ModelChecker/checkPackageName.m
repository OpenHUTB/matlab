function flag=checkPackageName(this)





    flag=true;

    sys_name=this.m_sys;
    targetLanguage=hdlget_param(sys_name,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')
        pkgParam='PackagePostfix';
        pacPostfix=hdlget_param(sys_name,pkgParam);

        if~strcmpi(pacPostfix,'_pac')
            flag=false;
            message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_package_name_error',pacPostfix);
            parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,pkgParam,sys_name);
            this.addCheck('warning',message,parameter,0);
        end
    end
end
