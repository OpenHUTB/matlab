function out=getTargetHardwareNamesForSoC()





    socSimTgtRootDir=fullfile(matlabroot,'toolbox','soc','hardwareboards');
    subFolders=dir(socSimTgtRootDir);
    out={};
    for i=1:numel(subFolders)
        folderName=fullfile(socSimTgtRootDir,subFolders(i).name,'registry',...
        'targethardware');
        if exist(folderName,'dir')
            allTgtDefFiles=dir(fullfile(folderName,'*.xml'));
            for j=1:numel(allTgtDefFiles)
                tgtInfo=codertarget.targethardware.TargetHardwareRegEntry(...
                fullfile(folderName,allTgtDefFiles(j).name),'');
                out=[out,tgtInfo.Name];
            end
        end
    end

    isfnd=which('soc.internal.register.addBoardsToStockSoCBoards');
    if~isempty(isfnd)
        out{end+1}=soc.internal.register.addBoardsToStockSoCBoards;
    end

end