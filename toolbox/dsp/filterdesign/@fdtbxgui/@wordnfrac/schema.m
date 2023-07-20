function schema





    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'wordnfrac',pk.findclass('abstractwordnfrac'));

    schema.prop(c,'WordLabel2','ustring');
    p=schema.prop(c,'WordLength2','ustring');
    set(p,'FactoryValue','16');

    p=schema.prop(c,'AutoScale','on/off');
    set(p,'FactoryValue','On','GetFunction',@getautoscale);

    p=schema.prop(c,'AutoScaleAvailable','on/off');
    set(p,'FactoryValue','On');

    p=schema.prop(c,'AutoScaleDescription','ustring');
    set(p,'FactoryValue','Avoid overflow');

    p=schema.prop(c,'MaxWord','posint');
    set(p,'FactoryValue',1);

    p=schema.prop(c,'Maximum','posint');
    set(p,'FactoryValue',4);

    p=schema.prop(c,'privFracLengths','string vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off',...
    'AccessFlags.Init','Off');


    function as=getautoscale(this,as)

        if strcmpi(this.AutoScaleAvailable,'off')
            as='off';
        end


