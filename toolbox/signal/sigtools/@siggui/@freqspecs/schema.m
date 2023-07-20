function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'freqspecs',pk.findclass('freqframe'));
    set(c,'Description','Frequency Specifications');


    schema.prop(c,'AutoUpdate','on/off');

    p=schema.prop(c,'Values','string vector');
    set(p,'SetFunction',@setvalues,'GetFunction',@getvalues);

    p=schema.prop(c,'Labels','string vector');
    set(p,'SetFunction',@setlabels,'GetFunction',@getlabels);


    function out=setlabels(hObj,out)

        set(getcomponent(hObj,'-class','siggui.labelsandvalues'),'Labels',out);
        out={''};


        function out=getlabels(hObj,out)

            out=get(getcomponent(hObj,'-class','siggui.labelsandvalues'),'Labels');
            if isempty(out),out={''};end


            function out=setvalues(hObj,out)

                set(getcomponent(hObj,'-class','siggui.labelsandvalues'),'Values',out);
                out={''};


                function out=getvalues(hObj,out)

                    out=get(getcomponent(hObj,'-class','siggui.labelsandvalues'),'Values');
                    if isempty(out),out={''};end


