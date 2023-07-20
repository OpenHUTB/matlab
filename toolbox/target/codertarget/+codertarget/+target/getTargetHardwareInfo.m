function ret=getTargetHardwareInfo(targetFolder,boardFolder,target,varargin)




    if isequal(nargin,3)
        targetType=0;
    else
        targetType=int8(varargin{1});
    end

    boardFiles=codertarget.utils.getFilesInFolder(boardFolder);
    if isempty(boardFiles)
        ret=[];
    else
        for i=1:numel(boardFiles)
            boardFile=fullfile(boardFolder,boardFiles(i).name);
            info=codertarget.targethardware.TargetHardwareRegEntry(boardFile,target);
            info.TargetFolder=targetFolder;
            info.TargetType=targetType;
            ret(i)=info;%#ok<*AGROW>
        end
    end
end