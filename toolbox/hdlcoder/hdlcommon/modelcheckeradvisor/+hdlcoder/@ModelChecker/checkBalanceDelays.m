function flag=checkBalanceDelays(this)




    flag=true;

    sys_name=this.m_sys;
    balanceDelays=hdlget_param(sys_name,'BalanceDelays');


    if strcmpi(balanceDelays,'off')
        flag=false;
        message=DAStudio.message('HDLShared:hdlmodelchecker:BalanceDelaysChecks_error');
        this.addCheck('warning',message,sys_name,1,message);
    end
end

