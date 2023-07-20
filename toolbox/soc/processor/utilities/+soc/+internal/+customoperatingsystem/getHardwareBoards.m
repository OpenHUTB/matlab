function[validBoards,hwBoardInfo]=getHardwareBoards





    allBoards=ioplayback.util.getValidBoards;
    validBoards={};
    hwBoardInfo={};
    for i=1:numel(allBoards)
        thisBoard=allBoards{i};
        hw=codertarget.targethardware.getTargetHardwareFromNameForSoC(thisBoard);
        if isempty(hw)
            continue;
        end
        [~,fName,~]=fileparts(hw.DefinitionFileName);

        hwBoardInfoFile=[fName,'_socb.json'];
        if isequal(exist(hwBoardInfoFile,'file'),2)
            validBoards{end+1}=thisBoard;%#ok<AGROW>
            hwBoardInfo{end+1}=jsondecode(fileread(hwBoardInfoFile));%#ok<AGROW>
        end
    end
end
