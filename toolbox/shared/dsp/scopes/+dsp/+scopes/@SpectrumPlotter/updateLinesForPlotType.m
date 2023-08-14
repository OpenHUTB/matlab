function updateLinesForPlotType(this)





    if strcmp(this.PlotMode,'Spectrum')||strcmp(this.PlotMode,'SpectrumAndSpectrogram')&&~this.CCDFMode

        if this.NormalTraceFlag
            [xdata,ydata]=getAllLinesData(this.Lines);
            setupNormalTraceLines(this,true);

            if strcmpi(this.PlotType,'stem')
                defaultMarker='.';
            else
                defaultMarker='none';
            end

            for i=1:length(this.LinePropertiesCache)
                this.LinePropertiesCache{i}.Marker=defaultMarker;
            end
            updateLineProperties(this);
            updateStemPlotBaseValue(this);
            setAllLinesData(this.Lines,xdata,ydata);
        end
    end
end
