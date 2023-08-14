

function AlertBindModeTool(mdl)


    editors=BindMode.utils.getAllEditorsForModel(mdl);
    for e=1:numel(editors)
        editors(e).sendMessageToTools('SLAlertBindModeTool');
    end
end