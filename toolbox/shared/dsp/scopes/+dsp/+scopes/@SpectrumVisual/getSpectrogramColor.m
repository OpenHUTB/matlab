function color=getSpectrogramColor(this,cDataValue)




    hPlotter=this.Plotter;
    if~isempty(hPlotter.hImage)
        colorMap=hPlotter.ColorMap;
        nColors=size(colorMap,1);
        cLim=get(hPlotter.Axes(1,2),'CLim');
        iColor=floor(((cDataValue-cLim(1))/diff(cLim))*nColors)+1;
        iColor=min(nColors,max(iColor,1));
        color=colorMap(iColor,:);
    else
        color=NaN(1,3);
    end
end
