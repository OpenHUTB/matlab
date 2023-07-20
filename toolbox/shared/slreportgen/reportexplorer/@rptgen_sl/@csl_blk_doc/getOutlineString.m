function s=getOutlineString(this)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_blk_doc:unlicensedComponentLabel'));
        return;

    end

    s=getString(message('RptgenSL:rsl_csl_blk_doc:docblockTextLabel'));