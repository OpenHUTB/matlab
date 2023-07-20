function nesl_opencomponentpath(componentPath)






    [sourceFile,isEditable]=...
    simscape.compiler.mli.internal.sourcefilefromcomponentpath(...
    componentPath);
    if isempty(sourceFile)
        errordlg(sprintf('Source file for %s is not found.',componentPath));
        return;
    end


    if isEditable
        edit(sourceFile);
    else
        errordlg(sprintf('Source file %s cannot be opened.',sourceFile));
        return;
    end

end
