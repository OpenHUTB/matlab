function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'magframe',pk.findclass('abstract_specsframe'));
    set(c,'Description','abstract');


    p=schema.prop(c,'Values','string vector');
    p.SetFunction=@set_values;
    p.GetFunction=@get_values;

    p=schema.prop(c,'Labels','string vector');
    p.SetFunction=@set_labels;
    p.GetFunction=@get_labels;


    function P=get_values(h,dummy)

        lvh=getcomponent(h,'-class','siggui.labelsandvalues');

        P=get(lvh,'Value');


        function dummy=set_values(h,P)

            lvh=getcomponent(h,'-class','siggui.labelsandvalues');

            set(lvh,'Values',P);

            dummy={''};


            function P=get_labels(h,dummy)

                lvh=getcomponent(h,'-class','siggui.labelsandvalues');

                P=get(lvh,'Labels');


                function dummy=set_labels(h,P)

                    lvh=getcomponent(h,'-class','siggui.labelsandvalues');

                    set(lvh,'Labels',P);

                    dummy={''};


