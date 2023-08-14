function textFcn=addNumOfCalls(obj,fcn_text,fcn,parent,nCalled)
    if nCalled>1
        textFcn=[fcn_text,' (',int2str(nCalled),')'];
    else
        textFcn=fcn_text;
    end
    if~isempty(parent)
        if nCalled>1
            textFcn=['<span style="white-space:nowrap" title="',obj.getMessage('CallSiteTooltip',parent,int2str(nCalled),fcn),'">',textFcn,'</span>'];
        else
            textFcn=['<span style="white-space:nowrap" title="',obj.getMessage('SingleCallSiteTooltip',parent,fcn),'">',textFcn,'</span>'];
        end
    end
end
