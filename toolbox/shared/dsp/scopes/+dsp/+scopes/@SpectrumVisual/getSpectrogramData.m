function[xData,yData,zData]=getSpectrogramData(this)





    xData=[];
    yData=[];
    zData=[];
    hPlotter=this.Plotter;
    if~isempty(hPlotter)
        hImage=hPlotter.hImage;
        if~isempty(hImage)&&ishghandle(hImage)
            xData=get(hImage,'XData');
            yData=get(hImage,'YData');
            zData=get(hImage,'CData');
        end
    end
end
