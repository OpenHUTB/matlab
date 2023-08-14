function[sourceFile,isEditable]=sourcefilefromblock(hBlock)





    sourceFile='';
    isEditable=false;
    functionString=simscape.compiler.sli.internal.functionstringfromblock(hBlock);

    if isempty(functionString)
        return;
    end

    [sourceFile,isEditable]=...
    simscape.compiler.mli.internal.sourcefilefromcomponentpath(functionString);

end
