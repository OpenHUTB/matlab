function onAxesTickColorChanged(this)





    axesTickColor=get(this.Axes(1,1),'XColor');
    hXLabel=get(this.Axes(1,1),'XLabel');
    hYLabel=get(this.Axes(1,1),'YLabel');
    hTitle=get(this.Axes(1,1),'Title');
    set([hXLabel,hYLabel,hTitle],'Color',axesTickColor);


    set(this.Axes(1,1),'GridColor',axesTickColor);
    set(this.Axes(1,2),'GridColor',axesTickColor);

end