function schema






    pk=findpackage('siggui');


    c=schema.class(pk,'labelsandvalues',pk.findclass('siggui'));

    p=schema.prop(c,'Maximum','double');
    set(p,'AccessFlags.PublicSet','Off','FactoryValue',4);


    p=schema.prop(c,'Values','string vector');
    set(p,'SetFunction',@setstrings);


    p=schema.prop(c,'Labels','string vector');
    set(p,'SetFunction',@setstrings);

    p=[...
    schema.prop(c,'HiddenLabels','posint_vector');...
    schema.prop(c,'HiddenValues','posint_vector');...
    schema.prop(c,'DisabledValues','posint_vector');...
    ];
    set(p,'SetFunction',@setlengths);


    e=schema.event(c,'UserModifiedSpecs');



    function out=setlengths(this,out)

        idx=find(out>this.Maximum);
        out(idx)=[];


        function out=setstrings(this,out)

            m=get(this,'Maximum');

            if length(out)>m
                error(message('signal:siggui:labelsandvalues:schema:TooManyStrings',m))
            end


