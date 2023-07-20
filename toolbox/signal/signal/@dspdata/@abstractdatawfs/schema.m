function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractdatawfs',pk.findclass('abstractdata'));
    set(c,'Description','abstract');


    p=schema.prop(c,'NormalizedFrequency','bool');
    set(p,...
    'SetFunction',@setnormalizedfrequency,...
    'AccessFlag.Serialize','off',...
    'GetFunction',@getnormalizedfrequency,...
    'AccessFlags.Init','Off',...
    'AccessFlags.Abortset','off');



    p=schema.prop(c,'privNormalizedFrequency','bool');
    set(p,'AccessFlag.PublicSet','off','AccessFlag.PublicGet','off');
    p.FactoryValue=true;


    p=schema.prop(c,'Fs','mxArray');
    set(p,...
    'AccessFlag.PublicSet','off',...
    'AccessFlag.Serialize','off',...
    'AccessFlags.Init','Off',...
    'SetFunction',@set_fs,...
    'GetFunction',@get_fs);


    p=schema.prop(c,'privFs','posdouble');
    set(p,'AccessFlag.PublicSet','off','AccessFlag.PublicGet','off');
    p.FactoryValue=1;


    function normfreq=setnormalizedfrequency(this,normfreq)


        error(message('signal:dspdata:abstractdatawfs:schema:settingRangePropertyNotAllowed','NormalizedFrequency','normalizefreq','help dspdata/normalizefreq'));


        function Fs=set_fs(this,Fs)


            if this.NormalizedFrequency
                error(message('signal:dspdata:abstractdatawfs:schema:settingFreqPropertyNotAllowed','Fs','NormalizedFrequency','normalizefreq(h,false,Fs)'));
            end

            if~isempty(Fs)&(~isnumeric(Fs)|~isscalar(Fs)|Fs==0)
                error(message('signal:dspdata:abstractdatawfs:schema:invalidSamplingFrequency','Fs'));
            end

            setprivfs(this,Fs);


            Fs=[];


            function Fs=get_fs(this,Fs)


                if this.NormalizedFrequency
                    Fs='Normalized';
                else
                    Fs=getprivfs(this);
                end


