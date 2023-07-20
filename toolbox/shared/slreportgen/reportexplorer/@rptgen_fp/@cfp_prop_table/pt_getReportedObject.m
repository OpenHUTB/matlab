function obj=pt_getReportedObject(c)










    obj=get(rptgen_sl.appdata_sl,'CurrentBlock');

    if~isempty(obj)
        if ischar(obj)
            blockObj=get_param(obj,'Object');
        end







        if~blockObj.isSLBlockFixedPoint
            error(message('rptgen:fp_cfp_prop_table:noFixedPointSupport'));
        end

    else
        error(message('rptgen:fp_cfp_prop_table:noBlockFound'));
    end
