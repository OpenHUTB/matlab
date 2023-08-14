function cbar=findColorBars(peerAxes)






    fig=ancestor(peerAxes,'figure');




    cbar=findobjinternal(fig,...
    '-class','matlab.graphics.illustration.ColorBar',...
    'Axes',peerAxes,...
    'HandleVisibility','on');

end
