function moduleNames=getSharedModuleName(covMode,folders)




    folders=strrep(folders,'\','/');
    moduleNames=cellstr("["+folders+"] ("+char(covMode)+")");