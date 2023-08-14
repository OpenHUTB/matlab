function[headers,sources,fullPaths]=getPtxFiles(files)












    ptxUtilsSrcDir='toolbox/shared/coder/coder/gpucoder/src/cuda';
    ptxUtilsHdrDir=[ptxUtilsSrcDir,'/export/include/cuda'];
    files{end+1}=[ptxUtilsHdrDir,'/MWPtxUtils.hpp'];
    files{end+1}=[ptxUtilsSrcDir,'/MWPtxUtils.cpp'];


    headersIndex=cellfun(@isHeader,files);
    sourcesIndex=~headersIndex;


    headers=cellfun(@getFileName,files(headersIndex),'UniformOutput',false);
    sources=cellfun(@getFileName,files(sourcesIndex),'UniformOutput',false);
    fullPaths=cellfun(@getFullPath,files,'UniformOutput',false);

    function bool=isHeader(file)

        headerExtensions={'.hpp','.h'};
        [~,~,extension]=fileparts(file);
        bool=any(strcmp(headerExtensions,extension));
    end

    function fileName=getFileName(filePath)

        [~,name,extension]=fileparts(filePath);
        fileName=[name,extension];
    end

    function fullPath=getFullPath(filePath)


        fullPath=fullfile(matlabroot,filePath);
    end
end
