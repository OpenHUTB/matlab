function domObj=MATLABFile(filePath)


















    import mlreportgen.utils.internal.*
    code=fileread(which(filePath));
    domObj=MATLABCode(code);

end