function[isTFTarget,board]=isTargetFrameworkTarget(board)











    if ischar(board)||isStringScalar(board)



        createCopy=true;
        tr=targetrepository.create(createCopy);

        board=tr.get('Board',board);
    end

    isTFTarget=~isempty(board)&&...
    ~isempty(board.Processors)&&~isempty(board.Processors(1).LanguageImplementations);
end
