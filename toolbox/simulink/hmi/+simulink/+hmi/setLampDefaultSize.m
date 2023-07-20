function setLampDefaultSize(lampPath)
    pos=get_param(lampPath,'Position');
    defaultHeight=61;
    defaultWidth=52;
    set_param(lampPath,'Position',...
    [pos(1),pos(2),pos(1)+defaultWidth,pos(2)+defaultHeight]);
end
