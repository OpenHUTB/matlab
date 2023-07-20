function[pathToRepository,files,libsList]=generateRepository(libHandle,targetRelease,returnListOfFiles,returnListOfLibs)






    r=LibraryBrowser.internal.RepositoryGenerator(libHandle,targetRelease);
    r.generate;
    if returnListOfFiles
        files=r.mRepositoryFiles;
    else
        files={};
    end
    if returnListOfLibs
        libsList=r.mOtherLibraries;
    else
        libsList={};
    end
    pathToRepository=r.mRepositoryPath;

end
