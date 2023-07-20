function schema




    pk=findpackage('siggui');


    if isempty(findtype('dspfwizDestination'))
        schema.EnumType('dspfwizDestination',{'Current','New','User defined'});
    end

    c=schema.class(pk,'dspfwiz',findclass(pk,'siggui'));

    p=schema.prop(c,'Filter','MATLAB array');
    set(p,'SetFunction',@setfilter);

    p=spcuddutils.addpostsetprop(c,'UseBasicElements','on/off',@set_usebasicelements);
    set(p,'FactoryValue','Off','Description','Build model using basic elements');

    schema.prop(c,'Destination','dspfwizDestination');

    p=schema.prop(c,'UserDefined','ustring');
    set(p,'FactoryValue','Untitled');

    p=schema.prop(c,'BlockName','ustring');
    set(p,'FactoryValue','Filter','Description','Block name');

    p=schema.prop(c,'OverwriteBlock','on/off');
    set(p,'GetFunction',@get_overwrite,...
    'Description','Overwrite generated ''%s'' block');

    p=[...
    schema.prop(c,'OptimizeZeros','on/off');...
    schema.prop(c,'OptimizeOnes','on/off');...
    schema.prop(c,'OptimizeNegOnes','on/off');...
    schema.prop(c,'OptimizeDelayChains','on/off');...
    schema.prop(c,'OptimizeScaleValues','on/off');...
    ];
    set(p(1),'Description','Optimize for zero gains');
    set(p(2),'Description','Optimize for unity gains');
    set(p(3),'Description','Optimize for negative gains');
    set(p(4),'Description','Optimize delay chains');
    set(p(1:4),'FactoryValue','On',...
    'GetFunction',@get_optimize);
    set(p(5),'FactoryValue','on',...
    'Description','Optimize for unity scale values',...
    'GetFunction',@get_optimizescalevalues);


    if isempty(findtype('FDAToolInputProcesingTypes'))
        schema.EnumType('FDAToolInputProcesingTypes',...
        {'Columns as channels (frame based)',...
        'Elements as channels (sample based)',...
        'Inherited (this choice will be removed - see release notes)'});
    end
    p=spcuddutils.addpostsetprop(c,'InputProcessing','FDAToolInputProcesingTypes',@set_inputprocessing);
    set(p,'FactoryValue','Columns as channels (frame based)');

    if isempty(findtype('FDAToolRateOptionsTypes'))
        schema.EnumType('FDAToolRateOptionsTypes',...
        {'Enforce single-rate processing','Allow multirate processing'});
    end
    p=spcuddutils.addpostsetprop(c,'RateOptions','FDAToolRateOptionsTypes',@set_rateoptions);
    set(p,'FactoryValue','Enforce single-rate processing');

    p=schema.prop(c,'privShowRateOptionsFlag','bool');
    set(p,'FactoryValue',true,'AccessFlags.PublicSet','Off','Visible','off');

    p=schema.prop(c,'privGUIPosition','double_vector');
    set(p,'AccessFlags.PublicSet','Off','Visible','off');


    function Hd=setfilter(~,Hd)

        if~isempty(Hd)&&~isa(Hd,'dfilt.basefilter')
            error(message('signal:siggui:dspfwiz:schema:InvalidParam'));
        end


        function ow=get_overwrite(this,ow)

            if strcmpi(this.Destination,'new')
                ow='off';
            end


            function opt=get_optimizescalevalues(this,opt)

                if~isa(this.Filter,'dfilt.abstractsos')
                    opt='off';
                end


                function opt=get_optimize(this,opt)

                    if strcmpi(this.UseBasicElements,'off')
                        opt='off';
                    end


