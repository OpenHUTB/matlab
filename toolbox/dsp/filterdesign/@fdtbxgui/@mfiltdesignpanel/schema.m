function schema




    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'mfiltdesignpanel',findclass(findpackage('siggui'),'sigcontainer'));

    if isempty(findtype('mfiltTypes'))
        schema.EnumType('mfiltTypes',{'Interpolator','Decimator','Fractional-rate converter'});
    end

    p=schema.prop(c,'InterpolationFactor','posint');
    set(p,'FactoryValue',2,'SetFunction',@setinterpolationfactor,...
    'GetFunction',@getinterpolationfactor);

    p=schema.prop(c,'DecimationFactor','posint');
    set(p,'FactoryValue',1,'SetFunction',@setdecimationfactor,...
    'GetFunction',@getdecimationfactor);

    p=schema.prop(c,'FrequencyUnits','signalFrequencyUnits');
    set(p,'SetFunction',@setfrequencyunits,'GetFunction',@getfrequencyunits);

    p=schema.prop(c,'Fs','ustring');
    set(p,'SetFunction',@setfs,'GetFunction',@getfs);

    p=schema.prop(c,'Type','mfiltTypes');
    set(p,'SetFunction',@settype,'GetFunction',@gettype);

    p=schema.prop(c,'CurrentFilter','MATLAB array');
    set(p,'SetFunction',@set_currentfilter);

    p=schema.prop(c,'Implementation','ustring');
    set(p,'SetFunction',@setimplementation,'GetFunction',@getimplementation);

    p=schema.prop(c,'DifferentialDelay','ustring');
    set(p,'FactoryValue','1');

    p=schema.prop(c,'NumberOfSections','ustring');
    set(p,'FactoryValue','2');

    p=schema.prop(c,'isDesigned','bool');
    set(p,'FactoryValue',false);


    p=[...
    schema.prop(c,'privType','mxArray');...
    schema.prop(c,'interpInterpolationFactor','mxArray');...
    schema.prop(c,'decimDecimationFactor','mxArray');...
    schema.prop(c,'srcInterpolationFactor','mxArray');...
    schema.prop(c,'srcDecimationFactor','mxArray');...
    ];
    set(p,'AccessFlags.Init','Off',...
    'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    schema.event(c,'FilterDesigned');


    function cf=set_currentfilter(this,cf)

        hs=getcomponent(this,'tag','implementation');

        if~isempty(hs)
            if isa(cf,'dfilt.dtffir')||isa(cf,'mfilt.abstractfirmultirate')
                enableselection(hs,'current');
            else
                disableselection(hs,'current');
            end
        end


        function frequ=setfrequencyunits(this,frequ)

            hfs=getcomponent(this,'fs');

            if~isempty(hfs)
                set(hfs,'Units',frequ);
            end

            set(this,'isDesigned',false);


            function frequ=getfrequencyunits(this,frequ)

                hfs=getcomponent(this,'fs');

                if~isempty(hfs)
                    frequ=get(hfs,'Units');
                end


                function fs=setfs(this,fs)

                    hfs=getcomponent(this,'fs');

                    if~isempty(hfs)
                        set(hfs,'Value',fs);
                    end

                    set(this,'isDesigned',false);


                    function fs=getfs(this,fs)

                        hfs=getcomponent(this,'fs');

                        if~isempty(hfs)
                            fs=get(hfs,'Value');
                        end


                        function imp=setimplementation(this,imp)

                            hs=getcomponent(this,'tag','implementation');

                            if isempty(hs),return;end

                            set(hs,'Selection',imp);


                            function imp=getimplementation(this,imp)

                                hs=getcomponent(this,'tag','implementation');

                                if isempty(hs),return;end

                                imp=get(hs,'Selection');
