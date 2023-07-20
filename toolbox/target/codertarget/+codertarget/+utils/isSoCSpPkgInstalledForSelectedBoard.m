function out=isSoCSpPkgInstalledForSelectedBoard(board)









    availableHWBoards=codertarget.internal.getHardwareBoardsForInstalledSpPkgs('soc',false);

    hardware=loc_getSoCHardwareBoards(board);




    if any(ismember(availableHWBoards,hardware.Name))





        out=isequal(sum(ismember(availableHWBoards,hardware.Name)),2);
    else
        out=ismember(hardware.Name,codertarget.internal.getCustomHardwareBoardNamesForSoC())&&...
        ~isempty(which('soc.internal.customboard.TargetHardwarePlugin'));
    end
end

function out=loc_getSoCHardwareBoards(board)

    hwInfo=codertarget.targethardware.getTargetHardware(board);
    if numel(hwInfo)>1
        for i=1:numel(hwInfo)
            if isequal(...
                hwInfo(i).BaseProductID,...
                codertarget.targethardware.BaseProductID.SOC)
                out=hwInfo(i);
                break;
            end
        end
    else
        out=hwInfo;
    end
end