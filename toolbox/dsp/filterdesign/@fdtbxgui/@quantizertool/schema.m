function schema




    package=findpackage('fdtbxgui');
    parent=findclass(findpackage('siggui'),'siggui');

    thisclass=schema.class(package,'quantizertool',parent);

    enumeratetypes;

    p=schema.prop(thisclass,'checkbox','bool');
    p.FactoryValue=true;

    p=schema.prop(thisclass,'quantizerclass','quantizer|unitquantizer');
    p.FactoryValue='quantizer';

    p=schema.prop(thisclass,'mode','quantizerMode');
    p.FactoryValue='fixed';

    p=schema.prop(thisclass,'roundmode','quantizerRoundMode');
    p.FactoryValue='floor';

    p=schema.prop(thisclass,'overflowmode','quantizerOverflowMode');
    p.FactoryValue='saturate';

    p=schema.prop(thisclass,'fixedformat','MATLAB array');
    p.FactoryValue=[16,15];

    p=schema.prop(thisclass,'floatformat','MATLAB array');
    p.FactoryValue=[32,8];

    p=schema.prop(thisclass,'ShowQuantizerClass','bool');
    p.FactoryValue=false;

    p=schema.prop(thisclass,'Label','ustring');
    p.FactoryValue='';

    schema.prop(thisclass,'LabelWidth','MATLAB array');

    p=schema.prop(thisclass,'ShowHeadings','bool');
    p.FactoryValue=false;


    function enumeratetypes

        if isempty(findtype('quantizer|unitquantizer'))
            schema.EnumType('quantizer|unitquantizer',{'quantizer','unitquantizer'});
        end

        if isempty(findtype('quantizerMode'))
            schema.EnumType('quantizerMode',{'fixed','ufixed','float','double','single','none'});
        end

        if isempty(findtype('quantizerRoundMode'))
            schema.EnumType('quantizerRoundMode',{'ceil','convergent','fix','floor','round'});
        end

        if isempty(findtype('quantizerOverflowMode'))
            schema.EnumType('quantizerOverflowMode',{'saturate','wrap'});
        end
