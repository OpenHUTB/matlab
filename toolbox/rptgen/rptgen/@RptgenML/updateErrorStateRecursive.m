function updateErrorStateRecursive(dao,varargin)




    dao.updateErrorState(varargin{:});

    dao=dao.down;
    while~isempty(dao);
        dao.updateErrorState(varargin{:});
        dao=dao.right;
    end