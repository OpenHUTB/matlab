function setButtonPanelPosition(this)





    set(this.fig,'Units','Pixels');
    figSize=get(this.fig,'Position');
    figWidth=figSize(3);
    prefSize=javaMethodEDT('getPreferredSize',java(this.prevPanelButtonPanel));
    prefHeight=prefSize.getHeight();
    set(this.prevPanelButtonPanelContainer,'Position',...
    [1,1,figWidth,prefHeight]);

end
