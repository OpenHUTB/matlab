function togglePinning(hTip)






    hFig=ancestor(hTip,'figure');

    if~isempty(hFig)
        dcm=datacursormode(hFig);

        if strcmp(dcm.Enable,'off')
            if strcmp(hTip.PinnedView,'on')
                ax=ancestor(hTip,'matlab.graphics.axis.AbstractAxes');
                delete(hTip);

                matlab.graphics.datatip.internal.generateDataTipLiveCode(ax,matlab.internal.editor.figure.ActionID.DATATIP_REMOVED);
            elseif~isNonLinear(hFig,hTip)
                hTip.PinnedView='on';
                tips=findAllTips(hFig);
                for i=1:length(tips)
                    if~isequal(hTip,tips(i))
                        delete(tips(i));
                    end
                end
            end
        end
    end

    function ret=isNonLinear(hFig,hTip)
        ax=ancestor(hTip,'Axes','node');
        ret=false;
        if matlab.ui.internal.isUIFigure(hFig)...
            &&(~isempty(ax)...
            &&isvalid(ax)...
            &&((isprop(ax,'YScale')...
            &&strcmp(ax.YScale,'log'))...
            ||(isprop(ax,'XScale')...
            &&strcmp(ax.XScale,'log'))...
            ||(isprop(ax,'ZScale')...
            &&strcmp(ax.ZScale,'log'))))
            ret=true;
        end
    end

    function tips=findAllTips(hContainer)
        tips=[];
        if~matlab.ui.internal.isUIFigure(hFig)
            return;
        end
        tips=findall(hContainer,'-class','matlab.graphics.shape.internal.PointDataTip');
        if isempty(tips)
            tips=matlab.graphics.shape.internal.PointDataTip.empty(1,0);
        else
            tips=reshape(tips,1,numel(tips));
        end
    end
end