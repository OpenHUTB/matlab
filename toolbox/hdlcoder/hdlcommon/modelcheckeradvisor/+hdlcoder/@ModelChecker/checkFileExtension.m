function flag=checkFileExtension(this)





    flag=true;

    sys_name=this.m_sys;
    targetLanguage=hdlget_param(sys_name,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')
        fileExtension=hdlget_param(sys_name,'VHDLFileExtension');

        if~strcmpi(fileExtension,'.vhd')&&~strcmpi(fileExtension,'.vhdl')
            flag=false;
            extensionStr='''.vhd'' or ''.vhdl''';
            message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_file_extension_error',targetLanguage,fileExtension,extensionStr);
            parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,'VHDLFileExtension',sys_name);
            this.addCheck('warning',message,parameter,0);
        end
    end

    if strcmpi(targetLanguage,'verilog')
        fileExtension=hdlget_param(sys_name,'VerilogFileExtension');

        if~strcmpi(fileExtension,'.v')
            flag=false;
            extensionStr='''.v''';
            message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_file_extension_error',targetLanguage,fileExtension,extensionStr);
            parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,'VerilogFileExtension',sys_name);
            this.addCheck('warning',message,parameter,0);
        end
    end
end
