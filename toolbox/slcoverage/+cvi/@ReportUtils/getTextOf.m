function str=getTextOf(id,index,elements,detailLevel)




    str=SlCov.CoverageAPI.getTextOf(id,index,elements,detailLevel);
    if~contains(str,'<a href')
        str=cvi.ReportUtils.str_to_html(str);
    end
