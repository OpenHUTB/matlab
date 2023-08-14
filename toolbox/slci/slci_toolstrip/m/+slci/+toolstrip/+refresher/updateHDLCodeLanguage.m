


function updateHDLCodeLanguage(cbinfo,action)

    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();
    action.selected=strcmpi(codeLanguage,'hdl');

end
