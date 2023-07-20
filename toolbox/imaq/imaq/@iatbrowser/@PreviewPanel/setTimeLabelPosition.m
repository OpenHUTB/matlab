function setTimeLabelPosition(this)






    set(this.fig,'Units','Pixels');
    figSize=get(this.fig,'Position');
    figWidth=figSize(3);

    set(this.prevPanelButtonPanelContainer,'Units','Pixels');
    buttonPanelPosition=get(this.prevPanelButtonPanelContainer,'Position');
    topOfButtonPanel=buttonPanelPosition(4);

    timeLabelVisibility=get(this.timeLabel,'Visible');
    set(this.timeLabel,'Visible','off')
    set(this.timeLabel,'Units','Character');
    set(this.timeLabel,'Position',[1,1,1,1]);
    set(this.timeLabel,'Units','Pixels');
    timeLabelSize=get(this.timeLabel,'Position');
    timeLabelHeight=timeLabelSize(4);

    set(this.timeLabel,'Position',...
    [3*figWidth/4,topOfButtonPanel,(figWidth/4)-timeLabelHeight,timeLabelHeight]);
    set(this.timeLabel,'Visible',timeLabelVisibility);

end
