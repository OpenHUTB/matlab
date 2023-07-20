function setLinkManager(obj,lm)
    if isa(lm,'coder.report.LinkManagerBase')
        obj.LinkManager=lm;
    end
end
