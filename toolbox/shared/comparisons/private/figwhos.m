function out=figwhos(varargin)




    figureCleanup=createFigureCleanup();%#ok<NASGU>

    out=whos(varargin{:});

end

