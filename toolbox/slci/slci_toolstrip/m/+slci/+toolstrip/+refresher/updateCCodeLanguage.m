


function updateCCodeLanguage(cbinfo,action)

    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();
    action.selected=strcmpi(codeLanguage,'c');

end

