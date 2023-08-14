function createColorBar(this)




    if~any(strcmp(this.PlotMode,{'Spectrogram','SpectrumAndSpectrogram'}))
        return
    end
    this.hColorBar=colorbar('peer',this.Axes(1,2),...
    'location','North','tag','SpectrogramColorBar');
    posCb=get(this.hColorBar,'Position');
    height=posCb(4)/1.5;
    set(this.hColorBar,'Position',[posCb(1:3),height]);
    set(this.hColorBar,'XAxisLocation','top');
    set(this.hColorBar,'UIContextMenu',[]);
end
