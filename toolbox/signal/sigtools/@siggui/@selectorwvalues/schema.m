function schema





    pk=findpackage('siggui');



    c=schema.class(pk,'selectorwvalues',pk.findclass('selector'));

    p=schema.prop(c,'AllowNonCurrentEditing','on/off');

    p=schema.prop(c,'Values','string vector');
    set(p,'SetFunction',@setvalues,'GetFunction',@getvalues);

    p=schema.prop(c,'HiddenValues','posint_vector');
    set(p,'SetFunction',@sethiddenvalues,'GetFunction',@gethiddenvalues);

    p=schema.prop(c,'Listeners','handle.listener vector');
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    function val=setvalues(this,val)

        hlnv=getcomponent(this,'-class','siggui.labelsandvalues');
        set(hlnv,'Values',val);


        function val=getvalues(this,val)

            hlnv=getcomponent(this,'-class','siggui.labelsandvalues');
            val=get(hlnv,'Values');


            function hval=sethiddenvalues(this,hval)

                hlnv=getcomponent(this,'-class','siggui.labelsandvalues');
                set(hlnv,'HiddenValues',hval);


                function hval=gethiddenvalues(this,hval)

                    hlnv=getcomponent(this,'-class','siggui.labelsandvalues');
                    hval=get(hlnv,'HiddenValues');


