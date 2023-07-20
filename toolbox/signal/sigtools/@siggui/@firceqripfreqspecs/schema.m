function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'firceqripfreqspecs',pk.findclass('freqframe'));
    set(c,'Description','Frequency Specifications');


    p=schema.prop(c,'AutoUpdate','on/off');

    if isempty(findtype('fireqrip_FreqOpts'))
        schema.EnumType('fireqrip_FreqOpts',{'cutoff','passedge','stopedge'});
    end


    p=schema.prop(c,'freqSpecType','fireqrip_FreqOpts');


    p=schema.prop(c,'Dynamic_Prop_Handles','schema.prop vector');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';


