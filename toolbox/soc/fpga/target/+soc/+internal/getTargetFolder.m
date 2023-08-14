function ret=getTargetFolder(boardName)




    ret='';
    hwInfo=codertarget.targethardware.getRegisteredTargetHardware;
    for i=1:numel(hwInfo)
        if isequal(hwInfo(i).Name,boardName)
            if~isempty(codertarget.targethardware.findHwBoardsForID(hwInfo(i),codertarget.targethardware.BaseProductID.SOC))
                ret=hwInfo(i).TargetFolder;
                return
            end
        end
    end
end