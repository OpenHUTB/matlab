
function getIPTestbenchSrcFileList(this)




    hCurDriver=hdlcurrentdriver;
    IPTestbenchHDLFileList=[];

    IPCoreHDLFiles=this.DownstreamIntegrationDriver.hIP.hIPEmitter.IPCoreHDLFileList;

    for i=1:length(IPCoreHDLFiles)
        [~,NAME,EXT]=fileparts(IPCoreHDLFiles{i}.ShortFilePath);
        IPTestbenchHDLFileList{end+1}=[NAME,EXT];
    end

    hCurDriver.cgInfo.hdlFiles=[IPTestbenchHDLFileList';hCurDriver.cgInfo.hdlFiles];

end