function outputString=getEvolutionOutputMessage(output)




    if~isempty(output.MissingDirectories)
        messageStr=getString...
        (message('evolutions:manage:MissingFiles'));
        fileList=output.MissingFiles;
    elseif~isempty(output.WriteProtectedFiles)
        messageStr=getString...
        (message('evolutions:manage:WriteProtectedFiles'));
        fileList=output.WriteProtectedFiles;
    elseif~isempty(output.WriteProtectedDir)
        messageStr=getString...
        (message('evolutions:manage:WriteProtectedDir'));
        fileList=output.WriteProtectedDir;
    else
        messageStr=getString...
        (message('evolutions:manage:UnknownError'));
        fileList=output.FilesThatCannotBeRestored;
    end
    outputString=evolutions.internal.ui.tools.prepareMessage(messageStr,fileList);
end
