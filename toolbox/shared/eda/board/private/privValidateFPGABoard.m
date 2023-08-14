function privValidateFPGABoard(boardFile)



    boardObj=eda.internal.boardmanager.ReadFPGAFile(boardFile);
    boardObj.validate;

