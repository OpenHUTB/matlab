function updateCCDFYAxis(this)



    set(this.Axes(1,1),'YLim',[0.0001,100],'YScale','log','YMinorGrid','off');



    if~isempty(resetplotview(this.Axes(1,1),'GetStoredViewStruct'))
        zoom(this.Axes(1,1),'reset');
    end

end
