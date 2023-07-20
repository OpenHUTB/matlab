function comp=getDownstreamComponent(dep,docType)




    loc=dep.DownstreamNode.Location{1};
    comp=dep.DownstreamComponent.Path;

    if comp==""
        [~,comp]=fileparts(loc);
    end

    if docType~="HTML-FILE"
        return
    end

    url=makeUrlToOpenComponent(loc,comp,dep.Type,"openDownstream");
    comp=addOpenActionIcon(comp,url,comp);
end
