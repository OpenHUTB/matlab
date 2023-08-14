function newMATFile=updateRTWMATFile(filename,srcFolder,incFolder)
    x=matfile(filename,'Writable',true);
    makeInfo=x.SFBInfoStruct;
    sourcePath=makeInfo.sourcePath;
    sourcePath=[sourcePath,{srcFolder}];
    includePath=makeInfo.includePath;
    includePath=[includePath,incFolder];
    makeInfo.sourcePath=sourcePath;
    makeInfo.includePath=includePath;
    x.SFBInfoStruct=makeInfo;
    newMATFile=filename;
end