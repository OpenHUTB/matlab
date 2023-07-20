function cs=loop_getContextString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        cs='';
        return;
    end

    cs=this.findDisplayName('Depth');
