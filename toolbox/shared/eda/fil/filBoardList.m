function varargout=filBoardList(varargin)













    mlock;



    persistent BoardObjList;


    defaultList={...
    'eda.board.AlteraArriaIIGX',...
    'eda.board.AlteraCycloneIIIDev',...
    'eda.board.AlteraCycloneIVGX',...
    'eda.board.AlteraDE2_115',...
    'eda.board.XilinxSP601',...
    'eda.board.XilinxSP605',...
    'eda.board.XilinxML401',...
    'eda.board.XilinxML402',...
    'eda.board.XilinxML403',...
    'eda.board.XilinxML505',...
    'eda.board.XilinxML506',...
    'eda.board.XilinxML507',...
    'eda.board.XilinxXUPV5',...
    'eda.board.XilinxML605',...
    'eda.board.XUPAtlys'};



    if isempty(BoardObjList)
        BoardObjList=cellfun(@eval,defaultList,'UniformOutput',false);
    end

    if nargin==0
        varargout={BoardObjList};
    else
        if strcmpi(varargin{1},'restore')
            BoardObjList=cellfun(@eval,defaultList,'UniformOutput',false);
        elseif strcmpi(varargin{1},'add')
            if nargin<2||~isa(varargin{2},'eda.board.FPGABoard')
                error(message('EDALink:filBoardList:InvalidBoardObj'));
            end
            BoardObjList{end+1}=varargin{2};
        else
            error(message('EDALink:filBoardList:InvalidFirstArg'));
        end
        varargout={};
    end


