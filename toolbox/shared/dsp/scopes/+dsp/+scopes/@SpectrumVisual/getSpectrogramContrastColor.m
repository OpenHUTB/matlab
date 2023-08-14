function color=getSpectrogramContrastColor(this)




    if~isempty(this.Plotter.hImage)
        hsv=rgb2hsv(this.Plotter.ColorMap);

        threshold=mean(hsv(:,3));
        if threshold<.9
            color=[1,1,1];
        else
            color=[0,0,0];
        end
    else
        color=ones(1,3);
    end
end
