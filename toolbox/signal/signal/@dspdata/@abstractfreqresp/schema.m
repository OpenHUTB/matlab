function schema





    pk=findpackage('dspdata');
    c=schema.class(pk,'abstractfreqresp',pk.findclass('abstractdatawfs'));


    findpackage('sigdatatypes');


    p=schema.prop(c,'Frequencies','double_vector');
    set(p,'AccessFlag.PublicSet','off');
    set(p,'SetFunction',@setfrequencies);
    p.FactoryValue=[];


    p=schema.prop(c,'CenterDC','bool');
    set(p,'AccessFlag.PublicSet','off','AccessFlag.PublicGet','off');
    p.FactoryValue=false;


    findclass(findpackage('dspdata'),'powermetadata');
    p=schema.prop(c,'Metadata','dspdata.powermetadata');
    set(p,'Visible','off');


    function freq=setfrequencies(this,freq)

        if~isempty(freq)&~isnumeric(freq)
            error(message('signal:dspdata:abstractfreqresp:schema:invalidFrequencyVector'));
        end

        freq=freq(:);


