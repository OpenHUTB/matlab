function schema




    pk=findpackage('fdtbxgui');
    spk=findpackage('siggui');


    c=schema.class(pk,'xformtool',spk.findclass('siggui'));

    p=schema.prop(c,'Transform','ustring');
    set(p,'Visible','off');

    p=schema.prop(c,'Labels','MATLAB array');
    set(p,'Visible','Off','FactoryValue',getlabels);

    p=schema.prop(c,'isTransformed','bool');
    set(p,'Visible','Off');

    p=schema.prop(c,'SourceType','ustring');
    set(p,'SetFunction',@set_sourcetype,'GetFunction',@get_sourcetype,...
    'FactoryValue','Lowpass');

    p=schema.prop(c,'TargetType','ustring');
    set(p,'SetFunction',@set_targettype,...
    'FactoryValue','Lowpass','AccessFlags.AbortSet','Off');

    p=schema.prop(c,'SourceFrequency','ustring');
    set(p,'FactoryValue','.4');

    p=schema.prop(c,'TargetFrequency','string vector');
    p.FactoryValue={'.3','.6'};

    p=schema.prop(c,'Filter','MATLAB array');
    set(p,'SetFunction',@set_filter,'GetFunction',@get_filter);

    p=schema.prop(c,'CurrentFs','MATLAB array');
    set(p,'SetFunction',@set_currentfs,'FactoryValue',defaultFs);

    p=schema.prop(c,'privFilter','mxArray');
    set(p,'Visible','Off','AccessFlags.Init','off');

    p=schema.prop(c,'privSourceType','ustring');
    set(p,'Visible','Off','AccessFlags.Init','off');

    p=schema.prop(c,'Listeners','handle.listener vector');
    set(p,'AccessFlags.PublicSet','off','AccessFlags.PublicGet','off');

    schema.event(c,'FilterTransformed');


    if isempty(findtype('FDAToolInputProcesingTypes'))
        schema.EnumType('FDAToolInputProcesingTypes',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end

    p=schema.prop(c,'InputProcessing','FDAToolInputProcesingTypes');
    set(p,'FactoryValue','Columns as channels (frame based)');


    function target=set_targettype(this,target)

        source=get(this,'SourceType');

        xform='';

        switch lower(source)
        case 'lowpass'
            switch lower(target)
            case 'lowpass'
                xform='iirlp2lp';
            case 'highpass'
                xform='iirlp2hp';
            case 'lowpass (fir)'
                xform='firlp2lp';
            case{'highpass (fir) narrowband','highpass (fir) wideband'}
                xform='firlp2hp';
            case 'bandpass'
                xform='iirlp2bp';
            case 'bandstop'
                xform='iirlp2bs';
            case 'multiband'
                xform='iirlp2mb';
            case 'bandpass (complex)'
                xform='iirlp2bpc';
            case 'bandstop (complex)'
                xform='iirlp2bsc';
            case 'multiband (complex)'
                xform='iirlp2mbc';
            end
        case 'highpass'
            switch lower(target)
            case 'highpass'
                xform='iirlp2lp';
            case 'lowpass'
                xform='iirlp2hp';
            case 'highpass (fir)'
                xform='firlp2lp';
            case{'lowpass (fir) narrowband','lowpass (fir) wideband'}
                xform='firlp2hp';
            case 'bandstop'
                xform='iirlp2bp';
            case 'bandpass'
                xform='iirlp2bs';
            case 'multiband'
                xform='iirlp2mb';
            case 'bandstop (complex)'
                xform='iirlp2bpc';
            case 'bandpass (complex)'
                xform='iirlp2bsc';
            case 'multiband (complex)'
                xform='iirlp2mbc';
            end
        case{'bandstop','bandpass'}
            if isempty(findstr('fir',lower(target)))%#ok<FSTR>
                xform='iirlp2lp';
            else
                xform='firlp2lp';
            end
        end

        set(this,'Transform',xform);
        set(this,'isTransformed',0);
        sendfiledirty(this);


        function stype=get_sourcetype(this,~)

            stype=get(this,'privSourceType');


            function stype=set_sourcetype(this,stype)

                set(this,'isTransformed',false,'privSourceType',stype);
                updateTargetType(this);
                stype='';


                function Hd=get_filter(this,~)

                    Hd=get(this,'privFilter');


                    function Hd=set_filter(this,Hd)

                        set(this,'isTransformed',false,'privFilter',Hd);
                        updateTargetType(this);
                        Hd=[];


                        function newFs=set_currentfs(this,newFs)


                            oldFs=get(this,'CurrentFs');

                            if isempty(oldFs),return;end


                            if~strcmpi(oldFs.units,newFs.units)
                                shift.source=get(this,'SourceFrequency');
                                shift.target=get(this,'TargetFrequency');
                                shift=scaleDefVals(shift,oldFs,newFs);
                                set(this,'SourceFrequency',shift.source);
                                set(this,'TargetFrequency',shift.target);
                            end


                            function updateTargetType(this)

                                strs=getValidTargetTypes(this);
                                if~any(strcmpi(this.TargetType,strs))
                                    set(this,'TargetType',strs{1});
                                end


                                function def=scaleDefVals(def,oldFs,newFs)


                                    if strcmpi(oldFs.units,'Normalized (0 to 1)')


                                        def.source=convert_to_normalized(def.source,4/newFs.value);
                                        for i=1:length(def.target)
                                            def.target{i}=convert_to_normalized(def.target{i},4/newFs.value);
                                        end
                                    elseif strcmpi(newFs.units,'Normalized (0 to 1)')
                                        def.source=convert_to_normalized(def.source,oldFs.value);
                                        for i=1:length(def.target)
                                            def.target{i}=convert_to_normalized(def.target{i},oldFs.value);
                                        end
                                    end


                                    function outvalue=convert_to_normalized(value,Fs)

                                        outvalue=str2num(value);%#ok<ST2NM>
                                        if isempty(outvalue)
                                            outvalue=value;
                                        else
                                            outvalue=num2str(outvalue/(Fs/2));
                                        end



                                        function Fs=defaultFs

                                            Fs.units='Normalized (0 to 1)';
                                            Fs.value=[];


                                            function xforms=getlabels

                                                xforms.iirlp2lp={'Specify desired frequency location:'};
                                                xforms.iirlp2hp=xforms.iirlp2lp;
                                                xforms.iirlp2bp={'Specify desired low frequency location:',...
                                                'Specify desired high frequency location:'};
                                                xforms.iirlp2bs=xforms.iirlp2bp;
                                                xforms.iirlp2mb={'Specify a vector of desired frequency locations:'};
                                                xforms.iirlp2bpc=xforms.iirlp2bp;
                                                xforms.iirlp2bsc=xforms.iirlp2bs;
                                                xforms.iirlp2mbc=xforms.iirlp2mb;
                                                xforms.firlp2lp={};
                                                xforms.firlp2hp={};


