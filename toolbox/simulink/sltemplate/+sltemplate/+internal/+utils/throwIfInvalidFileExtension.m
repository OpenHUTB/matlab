function throwIfInvalidFileExtension(filename)






    tExt=sltemplate.internal.Constants.getTemplateFileExtension;
    [~,~,ext]=slfileparts(filename);
    if~strcmp(ext,tExt)
        DAStudio.error('sltemplate:Package:InvalidFileExtension',filename,tExt);
    end
end