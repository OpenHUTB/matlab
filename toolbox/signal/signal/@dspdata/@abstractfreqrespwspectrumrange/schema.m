function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractfreqrespwspectrumrange',...
    pk.findclass('abstractfreqresp'));
    set(c,'Description','abstract');



    p=schema.prop(c,'SpectrumRange','SignalFrequencyRangeList');
    set(p,...
    'AccessFlag.Serialize','off',...
    'AccessFlags.Init','Off',...
    'SetFunction',@set_spectrumrange,...
    'GetFunction',@get_spectrumrange);



    p=schema.prop(c,'privSpectrumRange','SignalFrequencyRangeList');
    set(p,'AccessFlag.PublicSet','off','AccessFlag.PublicGet','off');
    p.FactoryValue='Half';


    function spectype=set_spectrumrange(this,spectype)


        error(message('signal:dspdata:abstractfreqrespwspectrumrange:schema:settingPropertyNotAllowed','SpectrumRange','halfrange','wholerange','help dspdata/halfrange','help dspdata/wholerange'));


        function specrange=get_spectrumrange(this,spectype)


            specrange=getspectrumtype(this);


