function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'firlpnormoptsframe',pk.findclass('lpnormoptionsframe'));

    schema.prop(c,'MinPhase','on/off');


    p=schema.prop(c,'isMinPhase','bool');
    set(p,'SetFunction',@setisminphase,'Visible','Off');


    function out=setisminphase(hObj,out)

        if out
            set(hObj,'MinPhase','on');
        else
            set(hObj,'MinPhase','off');
        end


