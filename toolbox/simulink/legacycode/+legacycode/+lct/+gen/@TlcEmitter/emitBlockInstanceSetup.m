



function emitBlockInstanceSetup(this,codeWriter)


    codeWriter.wFunctionDefStart('BlockInstanceSetup','(block, system) void');



    if this.HasWrapperOrIsCxx
        this.emitTestCodeFormatBlockStart(codeWriter);
        codeWriter.wBlockMiddle('%else');
    end

    codeWriter.wLine('%<LibBlockSetIsExpressionCompliant(block)>');


    if this.HasWrapperOrIsCxx
        this.emitTestCodeFormatBlockEnd(codeWriter);
    end


    codeWriter.wFunctionDefEnd();
