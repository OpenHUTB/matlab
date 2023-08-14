function setComponentBlockCallbacks(hBlk)




    required={...
    'CopyFcn','simscape.engine.sli.internal.componentblockcallback(gcbh,''COPY'')',...
    'PreCopyFcn','simscape.engine.sli.internal.componentblockcallback(gcbh,''PRECOPY'')',...
    'PreDeleteFcn','simscape.engine.sli.internal.componentblockcallback(gcbh,''PREDELETE'')'};



    modified=false;
    for idx=1:2:numel(required)
        if~strcmp(get_param(hBlk,required{idx}),required{idx+1})
            modified=true;
            break
        end
    end

    if modified
        set_param(hBlk,required{:});
    end

end