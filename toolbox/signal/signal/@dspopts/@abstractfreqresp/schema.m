function schema





    pk=findpackage('dspopts');
    c=schema.class(pk,'abstractfreqresp',...
    pk.findclass('abstractspectrumwfreqpoints'));
    set(c,'Description','abstract');

    schema.prop(c,'SpectrumRange','SignalFrequencyRangeList');

