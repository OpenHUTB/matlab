function success=exportVideoSignal(this,sig,bCmdLine)





    path=sdi.PluggableStorage.getSignalStoragePath(sig.ID);
    [~,~,ext]=fileparts(path);



    isMP4=strcmp(ext,this.FileType);
    if isempty(path)||~isMP4||exist(path,'file')==0
        this.displayError(message('SDI:sdi:ExportVideoIncorrectSignalError'),bCmdLine);
    end


    ok=copyfile(path,this.FileName);
    if~ok
        this.displayError(message('SDI:sdi:ExportVideoCopyFailureError'),bCmdLine);
    end

    success=true;
end
