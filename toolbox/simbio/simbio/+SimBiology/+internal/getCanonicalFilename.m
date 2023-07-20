function fileName=getCanonicalFilename(fileName)














    fileName=string(fileName);
    [pathToFile,fileName,ext]=fileparts(fileName);
    if ext==""
        ext=".sbproj";
    elseif ext~=".sbproj"
        error(message("SimBiology:diff:UnexpectedFileExtension",ext));
    end
    fileName=fullfile(pathToFile,fileName+ext);
    try
        fileNameWithAbsolutePath=builtin('_canonicalizepath',fileName);
        fileName=fileNameWithAbsolutePath;
    catch
        fileNameWithAbsolutePath=matlab.depfun.internal.which.callWhich(fileName);
        if~isempty(fileNameWithAbsolutePath)
            try
                fileNameWithAbsolutePath=builtin('_canonicalizepath',fileNameWithAbsolutePath);
                fileName=fileNameWithAbsolutePath;
            catch



            end
        end
    end
    fileName=string(fileName);

end