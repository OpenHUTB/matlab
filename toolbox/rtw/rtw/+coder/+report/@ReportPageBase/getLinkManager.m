function out=getLinkManager(obj)
    if isempty(obj.LinkManager)
        obj.LinkManager=coder.report.HTMLLinkManagerBase;
    end
    out=obj.LinkManager;
end
