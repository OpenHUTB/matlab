function addToolbarExplorationButtons(varargin)
















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

                zi=findobjinternal(tb,'Tag','Exploration.ZoomIn');
                zo=findobjinternal(tb,'Tag','Exploration.ZoomOut');
                panbtn=findobjinternal(tb,'Tag','Exploration.Pan');
                rt=findobjinternal(tb,'Tag','Exploration.Rotate');
                dc=findobjinternal(tb,'Tag','Exploration.DataCursor');
                br=findobjinternal(tb,'Tag','Exploration.Brushing');

                if isempty(zi)
                    zi=uitoolfactory(tb,'Exploration.ZoomIn');
                else
                    zi.Visible='on';
                end
                zi.Separator='on';

                if isempty(zo)
                    zo=uitoolfactory(tb,'Exploration.ZoomOut');
                else
                    zo.Visible='on';
                end

                if isempty(panbtn)
                    panbtn=uitoolfactory(tb,'Exploration.Pan');
                else
                    panbtn.Visible='on';
                end

                if isempty(rt)
                    rt=uitoolfactory(tb,'Exploration.Rotate');
                else
                    rt.Visible='on';
                end

                if isempty(dc)
                    dc=uitoolfactory(tb,'Exploration.DataCursor');
                else
                    dc.Visible='on';
                end

                if isempty(br)
                    br=uitoolfactory(tb,'Exploration.Brushing');
                else
                    br.Visible='on';
                end


                tb.Children=[tb.NodeChildren(1:end-5);...
                br;dc;rt;panbtn;zo;zi;tb.NodeChildren(end-4:end)];
            end
        end
    end
end