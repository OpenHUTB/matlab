function copyFileToBuildDir(entry,destDir)








    if~isa(entry,'RTW.TflCEntry')
        return;
    end

    if isprop(entry,'Implementation')
        doit(entry,entry.Implementation,destDir);
    elseif isprop(entry,'ImplementationVector')
        implVector=entry.ImplementationVector;
        if~isempty(implVector)
            [nrow,ncol]=size(implVector);
            index=(nrow*ncol)/2;
            for i=1:nrow
                implSet=implVector{index+i};
                for j=1:length(implSet)
                    impl=implSet(j);
                    doit(entry,impl,destDir);
                end
            end
        end
    end


    function doit(entry,impl,destDir)

        missingFiles=[];

        if~strcmp('',impl.SourceFile)
            missingFile=checkAndCopyFile(impl.SourceFile,...
            ['.';impl.SourcePath;entry.AdditionalSourcePaths;entry.SearchPaths],destDir);
            missingFiles=loc_addMissingFiles(missingFiles,missingFile);
        end


        if~strcmp('',impl.HeaderFile)
            hdrFile=regexprep(impl.HeaderFile,'"','');
            missingFile=checkAndCopyFile(hdrFile,...
            ['.';impl.HeaderPath;entry.AdditionalIncludePaths;entry.SearchPaths],destDir);
            missingFiles=loc_addMissingFiles(missingFiles,missingFile);
        end



        for i=1:length(entry.AdditionalSourceFiles)
            missingFile=checkAndCopyFile(entry.AdditionalSourceFiles{i},...
            ['.';impl.SourcePath;entry.AdditionalSourcePaths;entry.SearchPaths],destDir);
            missingFiles=loc_addMissingFiles(missingFiles,missingFile);
        end



        for i=1:length(entry.AdditionalHeaderFiles)
            hdrFile=regexprep(entry.AdditionalHeaderFiles{i},'"','');
            missingFile=checkAndCopyFile(hdrFile,...
            ['.';impl.HeaderPath;entry.AdditionalIncludePaths;entry.SearchPaths],destDir);
            missingFiles=loc_addMissingFiles(missingFiles,missingFile);
        end

        if~isempty(missingFiles)
            DAStudio.error('RTW:tfl:fileNotFoundError',missingFiles);
        end

        function missingFile=checkAndCopyFile(fileName,srcDirs,destDir)

            missingFile=[];

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
                fullSrcName=fullfile(srcDirs{i},nameSrcFile);
                existSrcFlag=dir(fullSrcName);
                if~isempty(existSrcFlag)
                    try
                        fullDesName=fullfile(destDir,nameSrcFile);
                        existDesFlag=dir(fullDesName);
                        if isempty(existDesFlag)||(existSrcFlag.datenum>existDesFlag.datenum)


                            loc_copyfile(fullSrcName,fullDesName);return;
                        else
                            return;
                        end
                    catch me
                        rethrow(me);
                    end
                end
            end

            missingFile=fileName;

            function loc_copyfile(src,des)

                fid_src=fopen(src,'rt');
                fid_des=fopen(des,'wt+');
                fwrite(fid_des,fread(fid_src,'char'),'char');
                fclose(fid_src);
                fclose(fid_des);

                function newMissingFiles=loc_addMissingFiles(missingFiles,missingFile)
                    newMissingFiles=missingFiles;
                    if~isempty(missingFile)
                        if isempty(newMissingFiles)
                            newMissingFiles=missingFile;
                        else
                            newMissingFiles=[newMissingFiles,', ',missingFile];
                        end
                    end
