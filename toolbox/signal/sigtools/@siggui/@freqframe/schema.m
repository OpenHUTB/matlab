function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'freqframe',pk.findclass('abstract_specsframe'));
    set(c,'Description','abstract');


    p=schema.prop(c,'AutoUpdate','on/off');

    p=schema.prop(c,'Fs','ustring');
    p.SetFunction=@set_fs;
    p.GetFunction=@get_fs;

    p=schema.prop(c,'Units','ustring');
    p.SetFunction=@set_units;
    p.GetFunction=@get_units;


    function P=get_fs(h,dummy)

        fsh=getcomponent(h,'-class','siggui.specsfsspecifier');
        P=get(fsh,'Value');


        function dummy=set_fs(h,P)

            fsh=getcomponent(h,'-class','siggui.specsfsspecifier');

            set(fsh,'Value',P);

            dummy='';


            function dummy=set_units(h,P)

                fsh=getcomponent(h,'-class','siggui.specsfsspecifier');

                set(fsh,'Units',P);

                dummy='';


                function P=get_units(h,dummy)

                    fsh=getcomponent(h,'-class','siggui.specsfsspecifier');

                    P=get(fsh,'Units');


