function comp=getUpstreamComponent(dep,docType)




    loc=dep.UpstreamNode.Location{1};
    componentPath=dep.UpstreamComponent.Path;

    if componentPath==""
        [~,comp]=fileparts(loc);
    else
        comp=i_applyHarnessDecoration(dep.UpstreamComponent.Name);
    end

    if docType~="HTML-FILE"
        return
    end

    url=makeUrlToOpenComponent(...
    loc,componentPath,dep.Type,"openUpstream");
    comp=addOpenActionIcon(comp,url,comp);
end



function comp=i_applyHarnessDecoration(comp)
    harnessPattern=".*\|\|TestHarness\|\|(.*)$";
    comp=regexprep(comp,harnessPattern,"$1");
end
