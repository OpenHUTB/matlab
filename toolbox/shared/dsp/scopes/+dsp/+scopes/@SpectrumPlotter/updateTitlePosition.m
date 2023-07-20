function updateTitlePosition(this)





    if~isempty(this.Title)
        if~this.CCDFMode&&strcmp(this.PlotMode,'Spectrogram')
            hTitle=get(this.Axes(1,2),'Title');
            hTitle.String=this.Title;
            hTitle.Visible='on';
            currentAxesUnits=get(this.Axes(1,2),'Units');
            currentTitleUnits=get(hTitle,'Units');
            set(hTitle,'Units','Pixels');
            set(this.Axes,'Units','Pixels');
            titlePos=get(hTitle,'Position');
            set(hTitle,'Position',[0,0,0]);
            posAx=get(this.Axes(1,2),'Position');
            pf=uiservices.getPixelFactor;
            set(hTitle,'Position',[titlePos(1),posAx(4)+48*pf,titlePos(3)]);
            set(hTitle,'Color',[0.6863,0.6863,0.6863]);
            set(hTitle,'Units',currentTitleUnits);
            set(this.Axes(1,1),'Units',currentAxesUnits)
            set(this.Axes(1,2),'Units',currentAxesUnits);

        elseif strcmp(this.PlotMode,'SpectrumAndSpectrogram')
            hTitle=get(this.Axes(1),'Title');
            hTitle.String=this.Title;
            hSpectrogramTitle=get(this.Axes(2),'Title');
            hSpectrogramTitle.Visible='off';
        end
    end
end

