function setStatLabelPosition(this)





    set(this.fig,'Units','Pixels');
    figSize=get(this.fig,'Position');
    figWidth=figSize(3);

    set(this.prevPanelButtonPanelContainer,'Units','Pixels');
    buttonPanelPosition=get(this.prevPanelButtonPanelContainer,'Position');
    topOfButtonPanel=buttonPanelPosition(4);

    set(this.statLabel,'Visible','off')
    set(this.statLabel,'Units','Character');
    set(this.statLabel,'Position',[1,1,1,1]);
    set(this.statLabel,'Units','Pixels');
    statLabelSize=get(this.statLabel,'Position');
    statLabelHeight=statLabelSize(4);

    set(this.statLabel,'Position',...
    [figWidth/4,topOfButtonPanel,figWidth/2,statLabelHeight]);
    set(this.statLabel,'Visible','on')

end
