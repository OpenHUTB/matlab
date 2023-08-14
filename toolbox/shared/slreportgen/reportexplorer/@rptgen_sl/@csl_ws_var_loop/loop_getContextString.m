function context=loop_getContextString(this)





    if~builtin('license','checkout','SIMULINK_Report_Gen')
        context='';

    else
        switch lower(getContextType(rptgen_sl.appdata_sl,this,false))
        case 'workspacevar'
            context=this.msg('WdgtValReportOnWSVar');
        case 'model'
            context=this.msg('WdgtValReportOnModel');
        case 'system';
            context=this.msg('WdgtValReportOnSystem');
        case{'signal','annotation'}
            context=this.msg('WdgtValReportOnNone');
        case 'block'
            context=this.msg('WdgtValReportOnBlock');
        otherwise
            context=this.msg('WdgtValReportOnAll');
        end
    end
