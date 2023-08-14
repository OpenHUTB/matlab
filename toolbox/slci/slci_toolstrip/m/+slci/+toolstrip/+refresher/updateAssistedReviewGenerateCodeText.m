


function updateAssistedReviewGenerateCodeText(cbinfo,action)

    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();

    if strcmpi(codeLanguage,'c')
        action.text=DAStudio.message('Slci:toolstrip:GenerateCCodeActionText');
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeTopActionDescription');
    elseif strcmpi(codeLanguage,'hdl')
        action.text=DAStudio.message('Slci:toolstrip:GenerateHDLCodeActionText');
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeRefActionDescription');
    elseif strcmpi(codeLanguage,'cuda')
        action.text=DAStudio.message('Slci:toolstrip:GenerateCUDACodeActionText');
    else
        action.text=DAStudio.message('Slci:toolstrip:GenerateCodeTopActionText');
    end

    isTop=ctx.getTopModel();
    if isTop
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeTopActionDescription');
    else
        action.description=DAStudio.message('Slci:toolstrip:GenerateCodeRefActionDescription');
    end
end
