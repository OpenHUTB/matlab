function schema





    pk=findpackage('filtdes');


    c=schema.class(pk,'fir1',findclass(pk,'dynamicMinOrdMethod'));


    p=schema.prop(c,'PassbandScale','on/off');
    p.FactoryValue='on';

    [w,lw]=findallwinclasses;
    if isempty(findtype('signalwindowslist'))
        schema.EnumType('signalwindowslist',{lw{1:end-1}});

    end
    p=schema.prop(c,'Window','signalwindowslist');
    p.FactoryValue='Kaiser';
    p.SetFunction=@set_win;


    p=schema.prop(c,'windowlistener','handle.listener');
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';

    p=schema.prop(c,'windowobject','mxArray');
    set(p,'setFunction',@checkclasstype);
    p.AccessFlags.PublicGet='off';
    p.AccessFlags.PublicSet='off';


    function value=checkclasstype(this,value)

        if~isempty(value)&&~isa(value,'sigwin.window')
            error(message('signal:filtdes:fir1:set_win:InvalidClass'));
        end
