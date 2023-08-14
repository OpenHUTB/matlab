function schema




    pk=findpackage('siggui');

    c=schema.class(pk,'pzeditor',pk.findclass('abstractmousefcns'));

    if isempty(findtype('sigguiPZEditorActions'))
        schema.EnumType('sigguiPZEditorActions',...
        {'Move Pole/Zero','Add Pole','Add Zero','Delete Pole/Zero'});
    end

    if isempty(findtype('sigguiPZEditorCoordinates'))
        schema.EnumType('sigguiPZEditorCoordinates',...
        {'Polar','Rectangular'});
    end


    p=[...
    schema.prop(c,'Action','sigguiPZEditorActions');...
    schema.prop(c,'Filter','MATLAB array');...
    schema.prop(c,'Gain','double_vector');...
    schema.prop(c,'Poles','double_vector');...
    schema.prop(c,'Zeros','double_vector');...
    schema.prop(c,'CoordinateMode','sigguiPZEditorCoordinates');...
    schema.prop(c,'ConjugateMode','on/off');...
    schema.prop(c,'CurrentSection','double');...
    ];


    set(p(2),'SetFunction',@setfilter);
    set(p(2),'GetFunction',@getfilter);
    set(p(3),'SetFunction',@setgain);
    set(p(3),'GetFunction',@getgain);
    set(p(4),'SetFunction',@setpoles);
    set(p(4),'GetFunction',@getpoles);
    set(p(5),'SetFunction',@setzeros);
    set(p(5),'GetFunction',@getzeros);
    set(p(7),'SetFunction',@setconjugatemode);
    set(p(8),'SetFunction',@setcurrentsection,'FactoryValue',1);



    p=[...
    schema.prop(c,'Roots','MATLAB array');...
    schema.prop(c,'AllRoots','MATLAB array');...
    schema.prop(c,'Listeners','handle.listener vector');...
    schema.prop(c,'PZValueListener','handle');...
    schema.prop(c,'CurrentRoots','handle vector');...
    schema.prop(c,'privFilter','MATLAB array');...
    ];
    set(p,'AccessFlags.PublicGet','Off','AccessFlags.PublicSet','Off');
    set(p(1),'GetFunction',@getroots,'SetFunction',@setroots);
    set(p(2),'SetFunction',@setallroots);

    schema.prop(c,'ErrorStatus','ustring');


    schema.event(c,'NewFilter');


    if isempty(findtype('FDAToolInputProcesingTypes'))
        schema.EnumType('FDAToolInputProcesingTypes',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end

    p=schema.prop(c,'InputProcessing','FDAToolInputProcesingTypes');
    set(p,'FactoryValue','Columns as channels (frame based)');


    function csec=setcurrentsection(hObj,csec)

        csec=getnset(hObj,'setcurrentsection',csec);


        function cmode=setconjugatemode(hObj,cmode)

            cmode=getnset(hObj,'setconjugatemode',cmode);


            function roots=getroots(hObj,roots)

                roots=getnset(hObj,'getroots');


                function roots=setroots(hObj,roots)

                    roots=getnset(hObj,'setroots',roots);


                    function gain=setgain(hObj,roots)

                        gain=getnset(hObj,'setgain',roots);


                        function gain=getgain(hObj,roots)

                            gain=getnset(hObj,'getgain');


                            function roots=setallroots(hObj,roots)

                                roots=getnset(hObj,'setallroots',roots);


                                function poles=getpoles(hObj,poles)

                                    poles=getnset(hObj,'getpoles');


                                    function zeros=getzeros(hObj,zeros)

                                        zeros=getnset(hObj,'getzeros');


                                        function poles=setpoles(hObj,poles)

                                            poles=getnset(hObj,'setpoles',poles);


                                            function zeros=setzeros(hObj,zeros)

                                                zeros=getnset(hObj,'setzeros',zeros);


                                                function filter=getfilter(hObj,filter)

                                                    filter=getnset(hObj,'getfilter');


                                                    function filter=setfilter(hObj,filter)

                                                        filter=hObj.getnset('setfilter',filter);


