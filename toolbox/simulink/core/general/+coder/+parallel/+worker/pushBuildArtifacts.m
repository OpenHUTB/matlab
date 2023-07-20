function subDir=pushBuildArtifacts(parBDir,masterAnchorFolder,pushParBuildArtifacts,hadErr,mdlRefs)





    import Simulink.internal.io.FileSystem;

    subDir='';




    cd(masterAnchorFolder);
    path(parBDir.savePath);
    Simulink.fileGenControl('clearParallelBuildInProgress');


    mexfile=[parBDir.mdlName,...
    coder.internal.modelRefUtil(parBDir.mdlName,...
    'getBinExt',false)];
    clear(mexfile);


    mexfile=[parBDir.mdlName,'_sfun'];
    clear(mexfile);



    if(pushParBuildArtifacts==Simulink.ModelReference.internal.ModelRefPushParBuildArtifacts.NONE)&&(hadErr==0)
        return;
    end


    if hadErr





        try
            FileSystem.robustCopy(fullfile(parBDir.tmpDir,'*'),parBDir.subDir);
        catch exc %#ok<NASGU>
        end
    else
        modelDir=fullfile(parBDir.mdlRefRootDir,parBDir.mdlName);
        wkrModelDir=fullfile(parBDir.primaryOutputDir,modelDir);




        sharedUtilsDir=fullfile(parBDir.primaryOutputDir,parBDir.sharedDir);
        if isfolder(sharedUtilsDir)
            FileSystem.robustCopy(sharedUtilsDir,parBDir.subSharedDir);
        end




        lndMdlBuildDir=fullfile(parBDir.subDir,[parBDir.mdlName,'_build']);


        skipFiles={[parBDir.mdlName,'.mk'],'build'};
        FileSystem.robustCopyExcluding(wkrModelDir,lndMdlBuildDir,skipFiles);




        wkrMdlRefRootDir=fullfile(parBDir.primaryOutputDir,parBDir.mdlRefRootDir);
        lndMdlRefRootDir=fullfile(parBDir.subDir,parBDir.mdlRefRootDir);
        tgtCopyFiles=FileSystem.dirFilenames(wkrMdlRefRootDir);
        FileSystem.robustCopyFiles(wkrMdlRefRootDir,lndMdlRefRootDir,tgtCopyFiles);








        if~parBDir.useSeparateCacheAndCodeGen
            wkrVarCacheDir=fullfile(parBDir.primaryOutputDir,parBDir.rootMdlRefSimDir,'varcache',parBDir.mdlName);
            if isfolder(wkrVarCacheDir)
                mastVarCacheDir=fullfile(parBDir.subDir,parBDir.rootMdlRefSimDir,'varcache',parBDir.mdlName);
                FileSystem.robustMkdir(mastVarCacheDir);
                FileSystem.robustCopy(wkrVarCacheDir,mastVarCacheDir);
            end
        end




        sfprjRootPath=fullfile('slprj','_sfprj');
        wkrSfprjDir=fullfile(parBDir.primaryOutputDir,sfprjRootPath);
        if isfolder(wkrSfprjDir)




            lndSfprjDir=fullfile(parBDir.subDir,sfprjRootPath);
            FileSystem.robustCopyExcluding(wkrSfprjDir,lndSfprjDir,mdlRefs)
        end











        skipDirs={parBDir.rootMdlRefSimDir,parBDir.mdlRefRootDir,parBDir.sharedDir,sfprjRootPath};
        FileSystem.robustCopyExcluding(parBDir.primaryOutputDir,parBDir.subDir,skipDirs);





        if parBDir.useSeparateCacheAndCodeGen
            lndSecondaryDir=fullfile(parBDir.subDir,'secondaryOutput');

            secondaryDirIsEmpty=isempty(FileSystem.dirContents(parBDir.secondaryOutputDir));
            if~secondaryDirIsEmpty
                FileSystem.robustCopy(parBDir.secondaryOutputDir,lndSecondaryDir);
            end
        end
    end

    subDir=parBDir.subDir;





    locCreateManifest(subDir);


    slprivate('removeDir',parBDir.tmpDir);
end

function locCreateManifest(dirName)











    count=1;
    maxCount=300;

    done=false;
    while(~done)
        dirInfo=dir(dirName);
        manifest={dirInfo(:).name};
        startIndex=regexp(manifest,'\w*[.]dmr-journal$');
        tf=cellfun(@isempty,startIndex);
        if all(tf)
            done=true;
            save([dirName,filesep,'manifest.mat'],'manifest');
        else
            count=count+1;
            if count>=maxCount
                DAStudio.error('Simulink:slbuild:parBuildCreateManifestError',...
                dirName);
            end
            pause(0.1);
        end
    end
    return;
end



