function orig_mode=setYYAxisInactiveYLimMode(ax,new_mode)

    if numel(ax(1).YAxis)==1
        orig_mode=[];
        return;
    else
        if ax.ActiveDataSpaceIndex==2
            yyaxis(ax,'left');
            orig_mode=ax.YLimMode;
            ax.YLimMode=new_mode;
            yyaxis(ax,'right');
        else
            yyaxis(ax,'right');
            orig_mode=ax.YLimMode;
            ax.YLimMode=new_mode;
            yyaxis(ax,'left');
        end
    end