function schema





    pk=findpackage('siggui');


    c=schema.class(pk,'selector',pk.findclass('sigcontainer'));


    p=schema.prop(c,'Name','ustring');
    set(p,'AccessFlags.PublicSet','off');

    p=schema.prop(c,'Selection','ustring');
    set(p,'SetFunction',@setselection,'GetFunction',@getselection,...
    'AccessFlags.AbortSet','Off');

    p=schema.prop(c,'SubSelection','ustring');
    set(p,'SetFunction',@setsubselection,'GetFunction',@getsubselection,...
    'AccessFlags.AbortSet','Off');

    p=schema.prop(c,'Identifiers','MATLAB array');
    set(p,'SetFunction',@setids);

    p=schema.prop(c,'Strings','MATLAB array');
    set(p,'SetFunction',@setstrs);

    schema.prop(c,'CSHTags','string vector');



    p=[...
    schema.prop(c,'DisabledSelections','string vector')...
    ,schema.prop(c,'privSelection','ustring')...
    ,schema.prop(c,'privSubSelection','ustring')...
    ,schema.prop(c,'SelectionListener','handle.listener')...
    ];
    set(p,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');

    schema.event(c,'NewSelection');
    schema.event(c,'NewSubSelection');


    function out=setids(hObj,out)

        if isrendered(hObj)&&length(out)~=length(hObj.Strings)
            error(message('signal:siggui:selector:schema:GUIErr'));
        end


        function out=setstrs(hObj,out)

            if isrendered(hObj)&&length(out)~=length(hObj.Identifiers)
                error(message('signal:siggui:selector:schema:GUIErr'));
            end


            function out=setselection(hObj,out)

                out=getnset(hObj,'setselection',out);


                function out=getselection(hObj,out)

                    out=getnset(hObj,'getselection',out);


                    function out=setsubselection(hObj,out)

                        out=getnset(hObj,'setsubselection',out);


                        function out=getsubselection(hObj,out)

                            out=getnset(hObj,'getsubselection',out);


