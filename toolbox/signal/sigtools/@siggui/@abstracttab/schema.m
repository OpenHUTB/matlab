function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'abstracttab',pk.findclass('sigcontainer'));
    set(c,'Description','abstract');

    p=schema.prop(c,'CurrentTab','posint');
    set(p,'FactoryValue',1,'SetFunction',@set_currenttab);

    p=schema.prop(c,'DisabledTabs','mxArray');
    set(p,'SetFunction',@set_disabledtabs);

    if isempty(findtype('leftrighttype'))
        schema.EnumType('leftrighttype',{'Left','Right'});
    end

    schema.prop(c,'TabAlignment','leftrighttype');

    p=[...
    schema.prop(c,'TabHandles','mxArray');...
    ];
    set(p,'Visible','Off');


    function ct=set_currenttab(this,ct)


        if any(ct==this.DisabledTab)
            error(message('signal:siggui:abstracttab:schema:GUIErr'));
        end


        function dt=set_disabledtabs(this,dt)

            ntabs=length(gettablabels(this));

            if any(this.CurrentTab==dt)
                set(this,'CurrentTab',min(setdiff(1:ntabs,dt)));
            end


