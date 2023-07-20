function out=modelIsLibrary(model)


    libType=get_param(model,'LibraryType');
    out=~strcmpi(libType,'None');
end
