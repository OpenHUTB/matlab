


function updateAssistedReviewCodeViewText(cbinfo,action)

    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();

    if strcmpi(codeLanguage,'hdl')

        action.description=DAStudio.message('Slci:toolstrip:CodeViewHDLActionDescription');
    elseif strcmpi(codeLanguage,'cuda')

        action.description=DAStudio.message('Slci:toolstrip:CodeViewCUDAActionDescription');
    else

        action.description=DAStudio.message('Slci:toolstrip:CodeViewCActionDescription');
    end

end
