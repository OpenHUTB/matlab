function schema





    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'modewordnfrac',pk.findclass('abstractwordnfrac'));

    if isempty(findtype('fdtbxguiQMode'))
        schema.EnumType('fdtbxguiQMode',{'Full precision','Keep LSB','Keep MSB','Specify all'});
    end


    p=schema.prop(c,'Mode','fdtbxguiQMode');
    set(p,'SetFunction',@setmode,'AccessFlags.AbortSet','Off');

    p=schema.prop(c,'ModeAvailable','on/off');
    set(p,'FactoryValue','on');

    p=schema.prop(c,'UMS_Listener','handle.listener');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    function mode=setmode(this,mode)

        h=getcomponent(this,'-class','siggui.labelsandvalues');

        if~isempty(h)
            switch lower(mode)
            case 'specify all'
                dv=[];
            case 'full precision'
                dv=(1:h.Maximum);
            otherwise
                dv=(2:h.Maximum);
            end
            set(h,'DisabledValues',dv);
        end


