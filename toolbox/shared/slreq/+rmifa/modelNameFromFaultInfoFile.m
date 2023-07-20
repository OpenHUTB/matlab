function mdl=modelNameFromFaultInfoFile(faultInfoFile)
    extInd=strfind(faultInfoFile,faultinfo.manager.faultInfoFileNameExtension());
    slashInd=max([strfind(faultInfoFile,'/'),strfind(faultInfoFile,'\')]);
    if isempty(slashInd)
        mdl=faultInfoFile(1:extInd(end)-1);
    else
        mdl=faultInfoFile(slashInd+1:extInd(end)-1);
    end
end