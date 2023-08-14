function[sourceFile,isEditable]=sourcefilefromcomponentpath(componentPath)





    sourceFile='';
    isEditable=false;

    sourceFileUsingWhich=which(componentPath);
    if~isempty(sourceFileUsingWhich)
        getSourceFile=ne_private('ne_sourcefile');
        [sourceFile,isEditable]=getSourceFile(sourceFileUsingWhich);
    end

end
