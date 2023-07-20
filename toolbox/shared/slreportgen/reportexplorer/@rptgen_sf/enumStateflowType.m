function e=enumStateflowType(varargin)






    e='rptgen_sf_SfType';
    if isempty(findtype(e))
        allTypes=listReportableTypes(rptgen_sf.appdata_sf);
        rptgen.enum(e,allTypes,allTypes);
    end
