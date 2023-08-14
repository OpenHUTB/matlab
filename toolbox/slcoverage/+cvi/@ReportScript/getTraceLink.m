function linkStr=getTraceLink(~,tags,isIncidental,~)






    if isIncidental
        labelTxt=DAStudio.message('Slvnv:simcoverage:cvhtml:IncidentalTraceTooltip');
    else
        labelTxt=DAStudio.message('Slvnv:simcoverage:cvhtml:TraceTooltip');
    end

    linkStr='';
    if~isempty(tags)
        t=split(tags,',');
        color='';
        allTagsTxt=[labelTxt,' &#13;',tags];
        linkStr=sprintf('<a href="#ref_trace_%s"><div %s title="%s"/><small>%s</small></a>',t{1},color,allTagsTxt,t{1});
    end
end