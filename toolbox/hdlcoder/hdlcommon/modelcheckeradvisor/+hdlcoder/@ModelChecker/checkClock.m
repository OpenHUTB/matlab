function flag=checkClock(this)





    flag=true;

    sys_name=this.m_sys;
    clkInputs=hdlget_param(sys_name,'ClockInputs');
    triggerAsClk=hdlget_param(sys_name,'TriggerAsClock');


    if strcmpi(clkInputs,'Multiple')
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_clockinput_error');
        this.addCheck('warning',message,sys_name,1,message);
    end


    if strcmpi(triggerAsClk,'on')
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:industry_std_triggerasclock_error');
        this.addCheck('warning',message,sys_name,1,message);
    end
end

