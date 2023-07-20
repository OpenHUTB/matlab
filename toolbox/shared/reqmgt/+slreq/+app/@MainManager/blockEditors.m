function unBlock=blockEditors()
    if slreq.app.MainManager.hasEditor
        doBlockEditors(true);
        unBlock=onCleanup(@()doBlockEditors(false));
    else
        unBlock=[];
    end
end

function doBlockEditors(block)
    editors=slreq.app.MainManager.getInstance.getAllViewers;
    for i=1:numel(editors)
        editors{i}.setUIBlock(block);
    end
end


