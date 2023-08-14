



function generateCodeAssistedReview(cbinfo)
    ctx=slci.toolstrip.util.getSlciAppContext(cbinfo.studio);

    codeLanguage=ctx.getCodeLanguage();
    if strcmpi(codeLanguage,'c')

        slci.toolstrip.util.generateCode(cbinfo,true);

    elseif strcmpi(codeLanguage,'hdl')

        stageName='HDLCoder';
        modelH=cbinfo.model.Handle;
        modelName=get_param(modelH,'Name');
        myStage=slci.internal.turnOnDiagnosticView(stageName,modelName);

        try
            makehdl(modelName);
        catch e
            slci.internal.outputMessage(e,'error');
        end

        myStage.delete;

    end


    mr_manager=slci.manualreview.Manager.getInstance;
    cv=mr_manager.getCodeView(cbinfo.studio);
    cv.refresh(codeLanguage);

end