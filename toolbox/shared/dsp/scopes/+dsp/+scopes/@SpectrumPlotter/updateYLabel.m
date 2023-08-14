function updateYLabel(this)





    if this.CCDFMode
        yLabel{1,1}=getString(message('dspshared:SpectrumAnalyzer:CCDFYLabel'));
        yLabel{1,2}='';
    else
        userText=this.privYLabel;
        postFix=this.SpectrumUnits;
        if~isempty(userText)
            postFix=['(',postFix,')'];
        end
        yLabel{1,1}=[userText,' ',postFix];
        if(strcmp(this.SpectrumType,'Power density')&&strcmp(this.PlotMode,'SpectrumAndSpectrogram'))||...
            (strcmp(this.SpectrumType,'Power density')&&strcmp(this.PlotMode,'Spectrum'))
            postFix=this.SpectrumUnits;
            postFix=[postFix,' / Hz'];
            if~isempty(userText)
                postFix=['(',postFix,')'];
            end
            yLabel{1,1}=[userText,' ',postFix];
        end
        yLabel{1,2}='';
        if strcmp(this.PlotMode,'Spectrogram')
            yLabel{1,1}='';
            yLabel{1,2}=getString(message('dspshared:SpectrumAnalyzer:HistoryXLabelWithUnits',this.TimeUnitsDisplay));
            yLabel{1,2}=[yLabel{1,2},'  \rightarrow'];
        end

        if strcmp(this.PlotMode,'SpectrumAndSpectrogram')
            yLabel{1,2}=getString(message('dspshared:SpectrumAnalyzer:HistoryXLabelWithUnits',this.TimeUnitsDisplay));
            yLabel{1,2}=[yLabel{1,2},'  \rightarrow'];
        end
    end
    for idx=1:length(this.Axes)
        if~strcmp(this.Axes(idx).YLabel.String,yLabel{idx})
            this.Axes(idx).YLabel.String=yLabel{idx};
        end
    end
end
