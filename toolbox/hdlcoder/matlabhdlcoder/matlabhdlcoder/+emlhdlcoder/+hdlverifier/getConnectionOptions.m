function[list,default]=getConnectionOptions



    try
        dt=com.mathworks.toolbox.coder.app.CoderRegistry.getInstance();
        prj=dt.getOpenProject();
        cfg=prj.getConfiguration();

        boardName=char(cfg.getParamAsString('param.hdl.FILBoardName'));

        hManager=eda.internal.boardmanager.BoardManager.getInstance;

        boardObj=hManager.getBoardObj(boardName);
        Connection=boardObj.getFILConnectionOptions;
        list=cellfun(@(x)x.Name,Connection,'UniformOutput',false);
    catch ME %#ok<NASGU>
        list={''};
    end

    default=list{1};


