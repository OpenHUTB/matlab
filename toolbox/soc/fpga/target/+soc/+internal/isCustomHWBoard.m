function value=isCustomHWBoard(board)



    switch board
    case codertarget.internal.getCustomHardwareBoardNamesForSoC
        value=true;
    otherwise
        value=false;
    end
end