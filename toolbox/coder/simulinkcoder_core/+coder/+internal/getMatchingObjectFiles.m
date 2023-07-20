function objectFiles=getMatchingObjectFiles(toolchain,sourceFiles,pathToObjFolder)





    dirObjFolder=dir(fullfile(pathToObjFolder,'*.*'));
    fileNamesObjFolder={dirObjFolder(:).name};


    extMap=i_getFileExtSourceObjMap(toolchain);

    foundObjectFile=false(size(sourceFiles));

    objectFiles=cell(size(sourceFiles));

    srcExtensions=extMap.keys;
    objExtensionsAll=extMap.values;

    for i=1:length(srcExtensions)
        srcExtension=['\.',regexptranslate('wildcard',srcExtensions{i}(2:end)),'$'];
        objExtensions=objExtensionsAll{i};


        matchingSrcsIdxLogical=...
        ~cellfun(@isempty,...
        regexp(sourceFiles,[srcExtension,'$'],'once'));
        matchingSrcsIdxNumeric=find(matchingSrcsIdxLogical);

        namesNoExt=regexprep(sourceFiles(matchingSrcsIdxLogical),srcExtension,'');

        for ii2=1:length(namesNoExt)

            candidateObjFiles=regexprep(objExtensions,'^\.',[namesNoExt{ii2},'.'],'once');
            if length(candidateObjFiles)>1


                actualObjFile=intersect(candidateObjFiles,fileNamesObjFolder);
            else




                actualObjFile=candidateObjFiles;
            end
            if length(actualObjFile)==1
                actualObjFile=actualObjFile{1};
                objectFiles{matchingSrcsIdxNumeric(ii2)}=actualObjFile;
                foundObjectFile(matchingSrcsIdxNumeric(ii2))=true;
            end
        end
    end

    srcFilesUnmatched=sourceFiles(~foundObjectFile);
    if~isempty(srcFilesUnmatched)
        if isempty(toolchain)
            objExts=regexprep(objExtensionsAll{1},'.*','"$0"');
            objExtsList=char(join(string(objExts),', '));

            DAStudio.error('PIL:pil:ModelObjectCodeMissingTMF',...
            join(string(srcFilesUnmatched),', '),...
            pathToObjFolder,objExtsList);
        else
            srcObjMappings=cell(size(srcExtensions));
            for i=1:length(srcObjMappings)
                objExts=regexprep(objExtensionsAll{i},'.*','"$0"');
                objExtsList=char(join(string(objExts),', '));
                srcObjMappings{i}=...
                sprintf('"%s > [%s]',srcExtensions{i},objExtsList);
            end
            srcObjMappings=char(join(string(srcObjMappings),', '));

            DAStudio.error('PIL:pil:ModelObjectCodeMissingToolchain',...
            join(string(srcFilesUnmatched),', '),...
            pathToObjFolder,srcObjMappings,toolchain.Name);
        end
    end


    function map=i_getFileExtSourceObjMap(toolchain)



        map=containers.Map;

        if isempty(toolchain)



            srcExtension='.*';


            objExtensions={'.o','.obj','.a','.lib'};


            map(srcExtension)=objExtensions;
        else
            [srcExtensions,objectExtensions]=...
            coder.make.internal.getFileExtensionsForToolchain(toolchain);

            for ii2=1:length(srcExtensions)
                map(srcExtensions{ii2})=objectExtensions(ii2);
            end
        end
