function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractfreqrespwspectrumtype',...
    pk.findclass('abstractfreqresp'));
    set(c,'Description','abstract');

    p=schema.prop(c,'SpectrumType','SignalSpectrumTypeList');
    set(p,...
    'AccessFlag.Serialize','off',...
    'AccessFlags.Init','Off',...
    'SetFunction',@set_spectrumtype,...
    'GetFunction',@get_spectrumtype);



    p=schema.prop(c,'privSpectrumType','SignalSpectrumTypeList');
    set(p,'AccessFlag.PublicSet','off','AccessFlag.PublicGet','off');
    p.FactoryValue='OneSided';


    function spectype=set_spectrumtype(this,spectype)


        error(message('signal:dspdata:abstractfreqrespwspectrumtype:schema:settingPropertyNotAllowed','SpectrumType','onesided','twosided','help dspdata/onesided','help dspdata/twosided'));


        function spectype=get_spectrumtype(this,spectype)


            spectype=getspectrumtype(this);


