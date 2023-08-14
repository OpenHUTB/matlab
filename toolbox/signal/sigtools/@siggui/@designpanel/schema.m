function schema




    pk=findpackage('siggui');

    c=schema.class(pk,'designpanel',pk.findclass('sigcontainer'));


    p=[...
    schema.prop(c,'Frames','siggui.siggui vector');...
    schema.prop(c,'AvailableTypes','MATLAB array');...
    schema.prop(c,'CurrentDesignMethod','handle');...
    schema.prop(c,'UserModifiedListener','MATLAB array');...
    schema.prop(c,'ActiveComponents','MATLAB array');...
    schema.prop(c,'PreviousStateInfo','MATLAB array');...
    schema.prop(c,'isLoading','bool');...
    ];
    p(2).FactoryValue=defaulttypes;
    p(3).AccessFlags.AbortSet='Off';

    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');


    schema.prop(c,'isDesigned','bool');

    p=schema.prop(c,'ResponseType','ustring');
    set(p,'SetFunction',@setfiltertype,'GetFunction',@getfiltertype);

    p=schema.prop(c,'SubType','ustring');
    set(p,'SetFunction',@setsubtype,'GetFunction',@getsubtype);

    p=schema.prop(c,'DesignMethod','ustring');
    set(p,'SetFunction',@setdesignmethod,'GetFunction',@getdesignmethod);

    p=schema.prop(c,'CurrentFs','MATLAB array');
    set(p,'GetFunction',@getcurrentfs);

    p=schema.prop(c,'ResponseTypeCSHTag','ustring');
    set(p,'FactoryValue','fdatool_filter_type_frame');

    schema.prop(c,'StaticResponse','on/off');

    schema.event(c,'FilterDesigned');


    if isempty(findtype('FDAToolInputProcesingTypes'))
        schema.EnumType('FDAToolInputProcesingTypes',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end

    p=schema.prop(c,'InputProcessing','FDAToolInputProcesingTypes');
    set(p,'FactoryValue','Columns as channels (frame based)');


    function types=defaulttypes

        fir.name='';fir.tag='';
        fir=repmat(fir,5,1);

        fir(1).name='Equiripple';
        fir(1).tag='filtdes.remez';

        fir(2).name='Least-squares';
        fir(2).tag='filtdes.firls';

        fir(3).name='Window';
        fir(3).tag='filtdes.fir1';

        fir(4).name='Constr. Least-squares';
        fir(4).tag='filtdes.fircls';

        fir(5).name='Complex Equiripple';
        fir(5).tag='filtdes.cremez';

        fir(6).name='Maximally flat';
        fir(6).tag='filtdes.firmaxflat';

        iir.name='';iir.tag='';
        iir=repmat(iir,5,1);

        iir(1).name='Butterworth';
        iir(1).tag='filtdes.butter';

        iir(2).name='Chebyshev Type I';
        iir(2).tag='filtdes.cheby1';

        iir(3).name='Chebyshev Type II';
        iir(3).tag='filtdes.cheby2';

        iir(4).name='Elliptic';
        iir(4).tag='filtdes.ellip';

        iir(5).name='Maximally flat';
        iir(5).tag='filtdes.iirmaxflat';

        types.lp(1).name='Lowpass';
        types.lp(1).tag='lp';
        types.lp(1).fir=fir;
        types.lp(1).iir=iir;

        types.lp(2).name='Raised-cosine';
        types.lp(2).tag='rcos';
        types.lp(2).fir=fir(3);
        types.lp(2).iir=[];

        types.hp(1).name='Highpass';
        types.hp(1).tag='hp';
        types.hp(1).fir=fir(1:5);
        types.hp(1).iir=iir(1:4);

        types.bp(1).name='Bandpass';
        types.bp(1).tag='bp';
        types.bp(1).fir=fir(1:4);
        types.bp(1).iir=iir(1:4);

        types.bs(1).name='Bandstop';
        types.bs(1).tag='bs';
        types.bs(1).fir=fir(1:4);
        types.bs(1).iir=iir(1:4);

        types.other(1).name='Differentiator';
        types.other(1).tag='diff';
        types.other(1).fir=fir(1:2);
        types.other(1).iir=[];

        types.other(2).name='Multiband';
        types.other(2).tag='multiband';
        types.other(2).fir=[fir(1:2);fir(4:5)];
        types.other(2).iir=[];

        types.other(3).name='Hilbert Transformer';
        types.other(3).tag='hilb';
        types.other(3).fir=fir(1:2);
        types.other(3).iir=[];

        types.other(4).name='Arbitrary Magnitude';
        types.other(4).tag='arbitrarymag';
        types.other(4).fir=fir(1:2);
        types.other(4).iir=[];



        function out=setfiltertype(h,type)

            out=getnset(h,'setresponsetype',type);


            function out=getfiltertype(h,type)

                out=getnset(h,'getresponsetype',type);


                function out=setdesignmethod(h,type)

                    out=getnset(h,'setdesignmethod',type);


                    function out=getdesignmethod(h,type)

                        out=getnset(h,'getdesignmethod',type);


                        function out=getcurrentfs(h,type)

                            out=getnset(h,'getcfs',type);


                            function out=getsubtype(h,type)

                                out=getnset(h,'getsubtype',type);


                                function out=setsubtype(h,type)

                                    out=getnset(h,'setsubtype',type);


