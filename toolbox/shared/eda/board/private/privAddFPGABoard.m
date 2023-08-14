function privAddFPGABoard(boardFile)


    boardFile=convertStringsToChars(boardFile);

    if~iscell(boardFile)
        boardFile={boardFile};
    end

    for m=1:numel(boardFile)
        if~ischar(boardFile{m})&&~string(boardFile{m})
            error(message('EDALink:boardmanager:FilePathNotChar'));
        else
            r=isFullPath(boardFile{m});
            if ispc
                assert(r,message('EDALink:boardmanager:WindowsNotFullPath'));
            else
                assert(r,message('EDALink:boardmanager:UnixNotFullPath'));
            end
        end
    end

    hManager=eda.internal.boardmanager.BoardManager.getInstance;

    boardNames=hManager.addBoardByFileName(boardFile);
    for m=1:numel(boardNames)
        disp(['Added FPGA board "',boardNames{m},'"']);
    end

end

function r=isFullPath(boardFile)
    if isempty(boardFile)
        r=false;
    elseif ispc
        if~isempty(regexp(boardFile,'^[a-zA-Z]:\','match','once'))

            r=true;
        elseif~isempty(regexp(boardFile,'\\','match','once'))

            r=true;
        else
            r=false;
        end
    else
        if boardFile(1)=='/'||boardFile(1)=='~'
            r=true;
        else
            r=false;
        end
    end
end