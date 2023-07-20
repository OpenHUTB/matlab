function flag=checkVisualization(this)






    flag=true;
    sys_name=this.m_sys;
    obj=get_param(sys_name,'Object');
    if~strcmpi(obj.ShowPortDataTypes,'on')
        flag=false;
        messagedsp=DAStudio.message('HDLShared:hdlmodelchecker:ModelSettingMessageSummary');
        message=DAStudio.message('HDLShared:hdlmodelchecker:datatype_visualization_error');
        this.addCheck('message',messagedsp,'',0,message);
    end
    if~strcmpi(obj.SampleTimeColors,'on')
        flag=false;
        messagedsp=DAStudio.message('HDLShared:hdlmodelchecker:ModelSettingMessageSummary');
        message=DAStudio.message('HDLShared:hdlmodelchecker:sampletime_visualization_error');
        this.addCheck('message',messagedsp,'',0,message);
    end
end
