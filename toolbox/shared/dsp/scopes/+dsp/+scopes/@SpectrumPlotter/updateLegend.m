function updateLegend(this)



    hLines=getAllLines(this);
    if isempty(hLines)
        newLegend='off';
    else
        newLegend=this.LegendVisibility;
    end
    hLegend=this.LegendHandle;
    if strcmpi(newLegend,'on')

        if ishghandle(hLegend)
            createLegend(this);


            createDisplayNameListeners(this);
            hLegend=this.LegendHandle;
            set(hLegend,'Visible','on');

            this.LegendLocation=hLegend.Location;
        else
            createLegend(this);


            createDisplayNameListeners(this);
        end
    elseif ishghandle(hLegend)

        legendcolorbarlayout(this.Axes(1),'off');

        delete(hLegend);
        this.LegendHandle=[];
    end
end
