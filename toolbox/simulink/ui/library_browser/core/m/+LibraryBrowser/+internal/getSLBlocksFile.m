function[slBlocksFile]=getSLBlocksFile(libMdl)






    narginchk(1,1);

    slBlocksFile=[];





    persistent libFileMappings;
    if isempty(libFileMappings)


        libFileMappings=containers.Map;
    else


        if isKey(libFileMappings,libMdl)
            slBlocksFile=libFileMappings(libMdl);

            if~isempty(which(slBlocksFile))
                return;
            else


                slBlocksFile=[];
            end
        end
    end


    if isempty(slBlocksFile)



        persistent cachedFileListLower;%#ok<*TLEV>
        persistent cachedFileListUpper;
        persistent allFilesRead;
        rawFileListLower=which('-all','slblocks');
        rawFileListUpper=which('-all','SLBLOCKS');
        if~isempty(allFilesRead)


            if isequal(cachedFileListLower,rawFileListLower)
                if isequal(cachedFileListUpper,rawFileListUpper)

                    return;
                end
            end

            allFilesRead=[];
        end

        cachedFileListLower=rawFileListLower;
        cachedFileListUpper=rawFileListUpper;
        persistent filesList;
        newFilesList=union(rawFileListLower,rawFileListUpper,'stable');
        newFilesList=newFilesList(cellfun('isempty',regexp(newFilesList,'\.p$')));
        diff=setdiff(newFilesList,filesList);


        if~isempty(diff)
            for i=1:length(diff)
                slBlocksFile=diff{i};
                filesList{end+1}=slBlocksFile;%#ok<AGROW>

                [~,libs,~,~,~,~,~,~,~]=LibraryBrowser.internal.getLibInfo(slBlocksFile);
                for j=1:length(libs)
                    lib=libs{j};
                    libFileMappings(lib)=slBlocksFile;
                    if strcmpi(lib,libMdl)


                        for k=j:length(libs)
                            libFileMappings(libs{k})=slBlocksFile;
                        end
                        return;
                    end
                end


                slBlocksFile=[];
            end


        end


        allFilesRead=true;
    end

end
