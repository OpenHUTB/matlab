function cs=loop_getContextString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')

        cs='';
    else
        cs=this.findDisplayName('Depth');
    end


