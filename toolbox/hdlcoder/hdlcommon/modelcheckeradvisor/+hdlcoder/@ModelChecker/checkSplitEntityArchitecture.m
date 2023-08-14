function flag=checkSplitEntityArchitecture(this)





    flag=true;

    sys_name=this.m_sys;
    targetLanguage=hdlget_param(sys_name,'TargetLanguage');

    if strcmpi(targetLanguage,'VHDL')
        split=hdlget_param(sys_name,'SplitEntityArch');

        if strcmpi(split,'on')
            flag=false;
            message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_split_entity_architecture_error');
            this.addCheck('warning',message,sys_name,0);
        end
    end
end