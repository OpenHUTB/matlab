function obj=pt_getReportedObject(c)








    obj=get(rptgen_sl.appdata_sl,['Current',c.ObjectType]);
    if isempty(obj)||isequal(obj,-1)
        error(message('RptgenSL:rsl_csl_prop_table:noCurrentForPropTableLabel',...
        lower(c.ObjectType)));
    end
