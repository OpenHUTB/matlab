function result=isBoardEmpty(obj)


    boardName=obj.get('Board');
    result=strcmp(boardName,obj.EmptyBoardStr)||strcmp(boardName,obj.AddNewBoardStr)||strcmp(boardName,obj.GetMoreBoardStr)||strcmp(boardName,obj.GetMoreStr);
end
