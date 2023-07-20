function flag=checkClockResetEnable(this)





    flag=true;

    sys_name=this.m_sys;
    clkParam='ClockInputPort';
    rstParam='ResetInputPort';
    clkenParam='ClockEnableInputPort';
    clkName=hdlget_param(sys_name,clkParam);
    rstName=hdlget_param(sys_name,rstParam);
    clkenName=hdlget_param(sys_name,clkenParam);



    if~contains(lower(clkName),{'clk','ck'})
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_clock_error',clkName);
        parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,clkParam,sys_name);
        this.addCheck('warning',message,parameter,1,message);
    end


    if~contains(lower(rstName),{'rstx','resetx','rst_x','reset_x','reset_n','RST_N'})
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_reset_error',rstName);
        parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,rstParam,sys_name);
        this.addCheck('warning',message,parameter,1,message);
    end


    if~contains(lower(clkenName),'en')
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_enable_error',clkenName);
        parameter=DAStudio.message('HDLShared:hdlmodelchecker:desc_Config_Param_link',sys_name,clkenParam,sys_name);
        this.addCheck('warning',message,parameter,1,message);
    end

end

