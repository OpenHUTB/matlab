function boardList=getTargetFrameworkBoardEntries()





    tr=targetrepository.create();
    targets=tr.get('Board',@codertarget.utils.isTargetFrameworkTarget);

    boardList=arrayfun(@codertarget.utils.getDropDownItemFromBoard,targets);
end
