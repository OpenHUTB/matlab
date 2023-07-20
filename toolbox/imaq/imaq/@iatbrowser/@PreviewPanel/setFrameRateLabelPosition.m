function setFrameRateLabelPosition(this)






    set(this.fig,'Units','Pixels');
    figSize=get(this.fig,'Position');

    figWidth=figSize(3);

    set(this.prevPanelButtonPanelContainer,'Units','Pixels');
    buttonPanelPosition=get(this.prevPanelButtonPanelContainer,'Position');
    topOfButtonPanel=buttonPanelPosition(4);

    frameRateLabelVisibility=get(this.frameRateLabel,'Visible');

    set(this.frameRateLabel,'Visible','off');
    set(this.frameRateLabel,'Units','Character');
    set(this.frameRateLabel,'Position',[1,1,1,1]);
    set(this.frameRateLabel,'Units','Pixels');
    frameRateLabelSize=get(this.frameRateLabel,'Position');
    frameRateLabelHeight=frameRateLabelSize(4);


    set(this.frameRateLabel,'Position',...
    [10,topOfButtonPanel,(figWidth/4)-frameRateLabelHeight,frameRateLabelHeight]);

    set(this.frameRateLabel,'Visible',frameRateLabelVisibility);

end