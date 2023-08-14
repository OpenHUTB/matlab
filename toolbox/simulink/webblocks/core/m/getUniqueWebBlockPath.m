function path=getUniqueWebBlockPath(basePath,blockName)
    path=[basePath,'/',blockName];
    blockNameNumericSuffix="";

    while(getSimulinkBlockHandle(path)~=-1)
        if(blockNameNumericSuffix=="")
            numericSuffixIndex=regexp(blockName,'\d+$');
            if(numericSuffixIndex)
                blockNameNumericSuffix=extractAfter(blockName,numericSuffixIndex-1);
                blockName=extractBefore(blockName,numericSuffixIndex);
            else
                blockNameNumericSuffix="1";
            end
        else
            blockNameNumericSuffix=int2str(str2double(blockNameNumericSuffix)+1);
        end
        path=strcat(basePath,'/',blockName,blockNameNumericSuffix);
    end
end
