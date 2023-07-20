function bIsLoaded=isLoaded(h)





    if isa(h,'SigLogSelector.MdlRefNode')
        bIsLoaded=~isempty(h.hBdNode)&&h.hBdNode.isLoaded;
    else
        bIsLoaded=~isempty(h.daobject);
    end

end
