function context=loop_getContextString(this)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        context='';

    else
        if strcmpi(this.LoopType,'list')
            context=this.msg('WdgtValReportOnCustomList');
        else
            context=this.msg('WdgtValReportOnAll');
        end
    end
