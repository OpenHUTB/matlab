function setCoreBlockProp(dlg,paramName,paramVal,opts)

    paramStr=paramVal;


    if nargin>3
        paramStr=opts{paramVal+1};
    elseif~ischar(paramStr)
        paramStr=num2str(paramVal);
    end


    ed=DAStudio.EventDispatcher;
    ed.broadcastEvent('PropertyUpdateRequestEvent',dlg,{paramName,paramStr});
end


