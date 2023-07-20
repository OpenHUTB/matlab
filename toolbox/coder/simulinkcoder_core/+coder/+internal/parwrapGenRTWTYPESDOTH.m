function parwrapGenRTWTYPESDOTH(dstDir,srcDirs)























    if~iscell(srcDirs)
        srcDirs={srcDirs};
    end

    for nSrcDir=1:length(srcDirs)

        srcDir=srcDirs{nSrcDir};
        fname=fullfile(srcDir,'rtwtypeschksum.mat');
        if(exist(fname,'file')~=2)

            continue;
        end
        srcDirRTWTYPESMatFile=load(fname);

        hardwareImp=srcDirRTWTYPESMatFile.hardwareImp;
        hardwareDeploy=srcDirRTWTYPESMatFile.hardwareDeploy;
        configInfo=srcDirRTWTYPESMatFile.configInfo;
        simulinkInfo=srcDirRTWTYPESMatFile.simulinkInfo;

        configInfo.GenDirectory=dstDir;
        configInfo.ModelName='';


        ansiDataTypeName=genRTWTYPESDOTH(hardwareImp,hardwareDeploy,configInfo,simulinkInfo);



        if ansiDataTypeName.tlcAddBanner_rtwtypes
            locCopyBannerAndTrailer(srcDir,dstDir,ansiDataTypeName.rtwtypesName)
        end
        if ansiDataTypeName.tlcAddBanner_multiwordTypes
            locCopyBannerAndTrailer(srcDir,dstDir,'multiword_types.h');
        end
        if ansiDataTypeName.tlcAddBanner_multiwordTypes
            locCopyBannerAndTrailer(srcDir,dstDir,'model_reference_types.h');
        end
        if ansiDataTypeName.tlcAddBanner_builtinTypeidTypes
            locCopyBannerAndTrailer(srcDir,dstDir,'builtin_typeid_types.h');
        end
    end
end

function locCopyBannerAndTrailer(wkrDir,mstDir,filename)



    wkrFile=fullfile(wkrDir,filename);
    if isfile(wkrFile)

        contents=fileread(wkrFile);
        [banner,trailer]=coder.internal.extractBannerTrailer(contents);

        hasBanner=~isempty(banner);
        hasTrailer=~isempty(trailer);

        if hasBanner||hasTrailer
            mstFile=fullfile(mstDir,filename);
            contents=fileread(mstFile);


            if hasBanner
                banner=sprintf('%s\n\n',banner);
            end
            if hasTrailer
                trailer=sprintf('\n%s\n',trailer);
            end


            contents=sprintf('%s%s\n%s',banner,strtrim(contents),trailer);


            f=fopen(mstFile,'w');
            fCleanup=onCleanup(@()fclose(f));
            fwrite(f,contents);
        end
    end
end


