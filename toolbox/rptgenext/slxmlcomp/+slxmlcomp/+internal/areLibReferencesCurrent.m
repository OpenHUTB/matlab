
function areCurrent=areLibReferencesCurrent(modelPath)



    areCurrent=false;

    libVersionQueryString='//System/Block[BlockType="Reference"]/LibraryVersion';
    libVersionQuery=Simulink.loadsave.Query(libVersionQueryString);
    sourceBlockQueryString='//System/Block[BlockType="Reference"]/SourceBlock';
    sourceBlockQuery=Simulink.loadsave.Query(sourceBlockQueryString);
    [libVersions,sourceBlocks]=Simulink.loadsave.findAll(modelPath,libVersionQuery,sourceBlockQuery);
    libVersions=libVersions{1};
    sourceBlocks=sourceBlocks{1};

    if numel(libVersions)~=numel(sourceBlocks)
        return
    end

    libVersionCache=containers.Map();

    for ii=1:numel(libVersions)
        libVersion=libVersions(ii);
        sourceBlock=sourceBlocks(ii);

        separatorIndex=strfind(sourceBlock.Value,'/');
        libName=sourceBlock.Value(1:separatorIndex-1);

        if(libVersionCache.isKey(libName))
            actualLibVersion=libVersionCache(libName);
        else
            actualLibVersion=i_GetLibraryVersion(libName);
            libVersionCache(libName)=actualLibVersion;
        end

        if~isempty(actualLibVersion)&&~strcmp(libVersion.Value,actualLibVersion)
            return
        end
    end

    areCurrent=true;
end


function version=i_GetLibraryVersion(libName)

    libraryPath=which([libName,'.slx']);
    if isempty(libraryPath)
        version=[];
    else
        version=Simulink.MDLInfo(libraryPath).ModelVersion;
    end

end

