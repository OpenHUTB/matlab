function[rlsPaths,rlsFiles]=getRLSPaths(lBuildFolder)




    rlsPaths={};
    rlsFiles={};


    codeDescFile=fullfile(lBuildFolder,'codedescriptor.dmr');
    if~isfile(codeDescFile)
        return;
    end
    repo=mf.zero.Model;
    mfdatasource.attachDMRDataSource...
    (codeDescFile,repo,mfdatasource.ToModelSync.None,...
    mfdatasource.ToDataSourceSync.None);
    model=coder.descriptor.Model.findModel(repo);
    if isempty(model)
        return;
    end



    orig_state=warning('query','MATLAB:subscripting:noSubscriptsSpecified');
    if strcmp(orig_state.state,'on')
        warning('off','MATLAB:subscripting:noSubscriptsSpecified');
        cleanupFcn=...
        onCleanup(@()warning(orig_state.state,'MATLAB:subscripting:noSubscriptsSpecified'));
    end

    numLibraryFiles=double(model.PregeneratedLibraryFiles.Size());

    rlsPaths=cell(1,numLibraryFiles);
    rlsFiles=cell(1,numLibraryFiles);

    for i=1:numLibraryFiles
        rlsPaths(i)=model.PregeneratedLibraryPaths(i);
        rlsFiles(i)=model.PregeneratedLibraryFiles(i);
    end
