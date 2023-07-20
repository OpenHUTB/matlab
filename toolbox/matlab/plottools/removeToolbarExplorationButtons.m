function removeToolbarExplorationButtons(varargin)















    if nargin~=1
        return;
    else
        figureHandles=varargin{1};

        if iscell(figureHandles)
            figureHandles=[figureHandles{:}];
        end
    end


    for i=1:numel(figureHandles)
        currentFigure=figureHandles(i);
        if~isempty(currentFigure)&&isa(currentFigure,'matlab.ui.Figure')

            tb=findobjinternal(currentFigure,'Type','uitoolbar','-and',...
            'Tag','FigureToolBar');
            if~isempty(tb)

                explorationBtns=findobjinternal(tb,'Tag','Exploration.Pan','-or',...
                'Tag','Exploration.Brushing','-or',...
                'Tag','Exploration.Rotate','-or',...
                'Tag','Exploration.ZoomOut','-or',...
                'Tag','Exploration.ZoomIn','-or',...
                'Tag','Exploration.DataCursor');


                delete(explorationBtns);
            end
        end
    end
end

