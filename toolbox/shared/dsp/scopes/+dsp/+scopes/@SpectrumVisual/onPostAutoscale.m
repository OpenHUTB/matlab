function onPostAutoscale(this,hasAutoscaled)





    if hasAutoscaled
        if~isSpectrogramMode(this)
            actXLim=this.Axes(1,1).XLim;
            if any(abs(actXLim-calculateXLim(this))<eps(diff(actXLim)))
                zoom(this.Axes(1,1),'reset');
            end
        end
    end


