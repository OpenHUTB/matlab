function[isSupported,isOpenMP]=compilerSupportsOpenMP()




    selectedCompiler=mex.getCompilerConfigurations('C','Selected');

    if isempty(selectedCompiler)
        isSupported=false;
        isOpenMP=false;
    else
        shortNameLower=lower(selectedCompiler.ShortName);

        isSupported=...
        strcmp(shortNameLower,'gcc')...
        ||strncmp(shortNameLower,'msvc',4)...
        ||strcmp(shortNameLower,'clang')...
        ||strncmp(shortNameLower,'mingw',5);

        isOpenMP=isSupported&&~strcmp(shortNameLower,'clang');
    end


