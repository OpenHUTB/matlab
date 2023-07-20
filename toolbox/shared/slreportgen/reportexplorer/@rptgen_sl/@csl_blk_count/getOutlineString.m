function s=getOutlineString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_count:unlicensedComponentLabel'));
        return;

    end

    s=getString(message('RptgenSL:rsl_csl_blk_count:blockTypeCountLabelNoSpace'));


