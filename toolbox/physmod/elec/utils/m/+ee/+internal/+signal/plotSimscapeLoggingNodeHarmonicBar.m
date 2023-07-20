function plotSimscapeLoggingNodeHarmonicBar(varargin)












    [harmonicOrder,harmonicMagnitude,fundamentalFrequency]=ee.internal.signal.getSimscapeLoggingNodeHarmonics(varargin{:});


    ee.internal.signal.plotHarmonicBarScaled(harmonicOrder,harmonicMagnitude,fundamentalFrequency);

end
