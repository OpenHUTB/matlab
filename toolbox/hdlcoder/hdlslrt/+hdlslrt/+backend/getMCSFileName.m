function mcsFileName=getMCSFileName(dutName,timestampStr)




    fileName=downstream.tool.createFileNameFromDUTName(dutName);
    mcsFileName=sprintf('%s_%s.mcs',fileName,timestampStr);

end