function schema





    pk=findpackage('fdtbxgui');
    c=schema.class(pk,'qtool',findclass(findpackage('siggui'),'abstracttab'));

    if isempty(findtype('fdtbxguiQtoolArithmetic'))
        schema.EnumType('fdtbxguiQtoolArithmetic',...
        {'Double-precision floating-point',...
        'Single-precision floating-point',...
        'Fixed-point'});
    end

    if isempty(findtype('QToolRoundMode'))
        schema.EnumType('QToolRoundMode',{'Ceiling','Nearest',...
        'Nearest (convergent)','Round','Zero','Floor'});
    end

    if isempty(findtype('QToolInputFracMode'))
        schema.EnumType('QToolInputFracMode',{'specify','calculate'});
    end

    p=schema.prop(c,'Filter','MATLAB array');
    set(p,'SetFunction',@setfilter,'GetFunction',@getfilter)

    p=schema.prop(c,'Arithmetic','fdtbxguiQtoolArithmetic');
    set(p,...
    'SetFunction',@setarithmetic,...
    'GetFunction',@getarithmetic,...
    'Description','Filter arithmetic');

    p=schema.prop(c,'isApplied','bool');
    set(p,'FactoryValue',true);

    p=schema.prop(c,'Unsigned','on/off');
    set(p,'Description','Use unsigned representation');

    p=schema.prop(c,'Normalize','on/off');
    set(p,'GetFunction',@getnormalize);

    p=schema.prop(c,'CastBeforeSum','on/off');
    set(p,'Description','Cast signals before accum.','FactoryValue','on',...
    'GetFunction',@getcastbeforesum);

    p=schema.prop(c,'RoundMode','QToolRoundMode');
    set(p,...
    'GetFunction',@getroundmode,...
    'Description','Rounding mode',...
    'FactoryValue','nearest (convergent)');

    p=schema.prop(c,'OverflowMode','QToolOverflowMode');
    set(p,...
    'GetFunction',@getoverflowmode,...
    'FactoryValue','Wrap');

    p=schema.prop(c,'DSPMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'SectionWordLengths','ustring');
    set(p,'FactoryValue','16');

    p=schema.prop(c,'SectionFracLengths','ustring');
    set(p,'FactoryValue','15');

    if isempty(findtype('ShortFilterInternalsType'))
        schema.EnumType('ShortFilterInternalsType',...
        {'Full','Minimum section word lengths','Specify word lengths','Specify all'});
    end

    p=schema.prop(c,'FilterInternals','ShortFilterInternalsType');
    set(p,'Description','Filter precision');

    p=[...
    schema.prop(c,'prevAppliedState','mxArray');...
    schema.prop(c,'privFilter','mxArray');...
    schema.prop(c,'Listeners','handle.listener vector');...
    ];
    set(p,'AccessFlags.PublicSet','Off','AccessFlags.PublicGet','Off');

    schema.event(c,'NewSettings');


    function roundmode=getroundmode(this,roundmode)

        if isa(this.Filter,'mfilt.abstractcic')
            roundmode='floor';
        elseif isfilterinternals(this)&&strncmpi(this.FilterInternals,'Full',4)
            roundmode='nearest (convergent)';
        end


        function overflowmode=getoverflowmode(this,overflowmode)

            if isa(this.Filter,'mfilt.abstractcic')||...
                (isfilterinternals(this)&&strncmpi(this.FilterInternals,'Full',4))
                overflowmode='wrap';
            end


            function arithmetic=getarithmetic(this,arithmetic)


                if isa(this.Filter,'mfilt.abstractcic')
                    arithmetic='fixed-point';
                end


                function cbs=getcastbeforesum(this,cbs)

                    h=getcomponent(this,'tag','accum');
                    if~isempty(h)
                        if strcmpi(get(h,'Mode'),'Full precision')
                            cbs='off';
                        end
                    end


                    function n=getnormalize(this,n)



                        if issupported(this)
                            if~isfield(qtoolinfo(this.Filter),'normalize')
                                n='off';
                            end
                        else
                            n='off';
                        end


