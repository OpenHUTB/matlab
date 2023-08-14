function plotSpectrogram(ax,gridset,bwp)




    cmap=parula(64);

    if isfield(gridset,'ResourceGrids')

        gridset=gridset.ResourceGrids;
    end


    for bp=1:length(gridset)


        image(ax,40*abs(gridset(bp).ResourceGridInCarrier(:,:,1)));
        axis(ax,'xy');
        colormap(ax,cmap);
        title(ax,getString(message('nr5g:waveformGeneratorApp:Spectrogram2DTitle',bp,bwp(bp).SubcarrierSpacing)));
        xlabel(ax,getString(message('nr5g:waveformGeneratorApp:Spectrogram2DXLabel')));
        ylabel(ax,getString(message('nr5g:waveformGeneratorApp:Spectrogram2DYLabel')));
    end