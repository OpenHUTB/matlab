function flag=checkGlobalReset(this)





    flag=true;
    sys_name=this.m_sys;

    synthtool=hdlget_param(sys_name,'SynthesisTool');
    resettype=hdlget_param(sys_name,'ResetType');
    isXilinxTool=any([strcmpi(synthtool,'Xilinx ISE'),strfind(synthtool,'Vivado')]);
    isAlteraTool=strcmpi(synthtool,'Altera Quartus II');

    if(isXilinxTool&&strcmpi(resettype,'Asynchronous'))
        flag=true;%#ok<NASGU>

        msg=message('HDLShared:hdlmodelchecker:err_runSynchronousResetChecks').getString();
        this.addCheck('warning',msg,this.m_DUT,0);
        flag=false;
    elseif isAlteraTool&&strcmpi(resettype,'Synchronous')
        flag=true;%#ok<NASGU>

        msg=message('HDLShared:hdlmodelchecker:err_runAsynchronousResetChecks').getString();
        this.addCheck('warning',msg,this.m_DUT,0);
        flag=false;
    end
end