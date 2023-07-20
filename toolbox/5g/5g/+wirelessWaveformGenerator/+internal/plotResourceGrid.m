function plotResourceGrid(ax,waveconfig,gridset,isDownlink,varargin)




    if isDownlink
        wirelessWaveformGenerator.internal.plotDLResourceGrid(ax,waveconfig,gridset,varargin{:});
    else
        wirelessWaveformGenerator.internal.plotULResourceGrid(ax,waveconfig,gridset,varargin{:});
    end