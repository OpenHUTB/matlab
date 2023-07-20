function[runtimeLibraries,linkLibraries]=getLinkAndRuntimeLibs(libraries)





    linkLibraries={};
    runtimeLibraries={};

    importExt=getLibraryExtension('import');
    dynamicExt=getLibraryExtension('dynamic');
    staticExt=getLibraryExtension('static');

    for fileCell=libraries
        file=fileCell{1};
        [~,~,ext]=fileparts(file);
        used=false;

        if isequal(ext,dynamicExt)
            used=true;
            runtimeLibraries{end+1}=file;
        end
        if isequal(ext,importExt)||isequal(ext,staticExt)

            used=true;
            linkLibraries{end+1}=file;
        end
        if~used

            linkLibraries{end+1}=file;
        end
    end
end