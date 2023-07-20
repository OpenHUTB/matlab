


function updateCUDACodeLanguage(cbinfo,action)

    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();
    action.selected=strcmpi(codeLanguage,'cuda');

end
