function copyFileToBuildDirPtxSpecial(entry,destDir)








    if~isa(entry,'RTW.TflCEntry')
        return;
    end

    configObj={};
    configObjW={};
    mexInfoFile=fullfile(destDir,'tmp_configinfo.mat');
    libInfoFile=fullfile(destDir,'codeInfo.mat');

    if exist(mexInfoFile,'file')
        configObjW=load(mexInfoFile);
    elseif exist(libInfoFile,'file')
        configObjW=load(libInfoFile);
    end

    if~isempty(configObjW)
        configObj=configObjW.configInfo;
    end

    if isprop(entry,'Implementation')
        doit(entry,entry.Implementation,destDir,configObj);
    elseif isprop(entry,'ImplementationVector')
        implVector=entry.ImplementationVector;
        if~isempty(implVector)
            [nrow,ncol]=size(implVector);
            index=(nrow*ncol)/2;
            for i=1:nrow
                implSet=implVector{index+i};
                for j=1:length(implSet)
                    impl=implSet(j);
                    doit(entry,impl,destDir,configObj);
                end
            end
        end
    end


    function doit(entry,impl,destDir,configObj)


        if~strcmp('',impl.SourceFile)
            checkAndCopyFile(impl.SourceFile,...
            ['.';impl.SourcePath;entry.AdditionalSourcePaths;entry.SearchPaths],destDir,configObj);
        end


        if~strcmp('',impl.HeaderFile)
            hdrFile=regexprep(impl.HeaderFile,'"','');
            checkAndCopyFile(hdrFile,...
            ['.';impl.HeaderPath;entry.AdditionalIncludePaths;entry.SearchPaths],destDir,configObj);
        end


        for i=1:length(entry.AdditionalSourceFiles)
            checkAndCopyFile(entry.AdditionalSourceFiles{i},...
            ['.';impl.SourcePath;entry.AdditionalSourcePaths;entry.SearchPaths],destDir,configObj);
        end


        for i=1:length(entry.AdditionalHeaderFiles)
            hdrFile=regexprep(entry.AdditionalHeaderFiles{i},'"','');
            checkAndCopyFile(hdrFile,...
            ['.';impl.HeaderPath;entry.AdditionalIncludePaths;entry.SearchPaths],destDir,configObj);
        end

        function checkAndCopyFile(fileName,srcDirs,destDir,configObj)

            srcDirs=RTW.expandToken(srcDirs);
            destDir=RTW.expandToken(destDir);

            [~,idSrcFile,extSrcFile]=fileparts(fileName);

            if isempty(extSrcFile)
                nameSrcFile=idSrcFile;
            else
                nameSrcFile=[idSrcFile,extSrcFile];
            end

            for i=1:length(srcDirs)
                if strcmp('',srcDirs{i})
                    srcDirs{i}='.';
                end
                fullSrcName=fullfile(srcDirs{i},getShippedFileName(nameSrcFile));
                existSrcFlag=dir(fullSrcName);
                if~isempty(existSrcFlag)
                    try
                        fullDestName=fullfile(destDir,nameSrcFile);
                        existDesFlag=dir(fullDestName);
                        if isempty(existDesFlag)||(existSrcFlag.datenum>existDesFlag.datenum)




                            fixedSrcFileName=getComputeSpecificPtxFileName(fullfile(srcDirs{i},nameSrcFile),configObj);


                            loc_copyfile(fixedSrcFileName,fullDestName);return;
                        else
                            return;
                        end
                    catch me
                        rethrow(me);
                    end
                end
            end

            DAStudio.error('RTW:tfl:fileNotFoundError',fileName);

            function loc_copyfile(src,des)

                fid_src=fopen(src,'rt');
                fid_des=fopen(des,'wt+');
                fwrite(fid_des,fread(fid_src,'char'),'char');
                fclose(fid_src);
                fclose(fid_des);

                function fileName=getShippedFileName(file)
                    [path,name,ext]=fileparts(file);
                    ptxSuffix='_latest';
                    if endsWith(name,'_mw_ptx')&&strcmp(ext,'.cu')
                        fileName=fullfile(path,[name,ptxSuffix,ext]);
                    else
                        fileName=file;
                    end

                    function ptxFileName=getComputeSpecificPtxFileName(origName,configObj)
                        if isempty(configObj)||isempty(configObj.GpuConfig)||~isempty(configObj.GpuConfig.CustomComputeCapability)
                            ptxFileName=getShippedFileName(origName);
                            return;
                        end

                        if~endsWith(origName,'_mw_ptx.cu')
                            ptxFileName=getShippedFileName(origName);
                            return;
                        end

                        [dirName,idSrcFile,extSrcFile]=fileparts(origName);
                        computeVersion=configObj.GpuConfig.ComputeCapability;
                        computeString=strrep(computeVersion,'.','');
                        srcFileNameWithComputeVersion=[idSrcFile,'_sm',computeString,extSrcFile];
                        newFullFileName=fullfile(dirName,srcFileNameWithComputeVersion);

                        existSrcFlag=dir(newFullFileName);
                        if isempty(existSrcFlag)
                            ptxFileName=getShippedFileName(origName);
                        else
                            ptxFileName=newFullFileName;
                        end





