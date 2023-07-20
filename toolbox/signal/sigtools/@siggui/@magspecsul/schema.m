function schema





    pk=findpackage('siggui');
    c=schema.class(pk,'magspecsul',pk.findclass('abstract_specsframe'));
    set(c,'Description','Magnitude Specifications');

    p=schema.prop(c,'Labels','string vector');
    set(p,'SetFunction',@setlabels,'GetFunction',@getlabels);

    p=schema.prop(c,'UpperValues','string vector');
    set(p,'SetFunction',@setupper,'GetFunction',@getupper);

    p=schema.prop(c,'LowerValues','string vector');
    set(p,'SetFunction',@setlower,'GetFunction',@getlower);


    function out=setlabels(hObj,out)

        set(getcomponent(hObj,'Upper'),'Labels',out);


        function out=getlabels(hObj,out)

            out=get(getcomponent(hObj,'Upper'),'Labels');


            function out=setupper(hObj,out)

                set(getcomponent(hObj,'Upper'),'Values',out);


                function out=getupper(hObj,out)

                    out=get(getcomponent(hObj,'Upper'),'Values');


                    function out=setlower(hObj,out)

                        set(getcomponent(hObj,'Lower'),'Values',out);


                        function out=getlower(hObj,out)

                            out=get(getcomponent(hObj,'Lower'),'Values');

