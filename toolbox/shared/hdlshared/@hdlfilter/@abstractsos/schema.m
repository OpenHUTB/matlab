function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'abstractsinglestage');
    this=schema.class(pk,'abstractsos',parent);

    schema.prop(this,'Coefficients','mxArray');

    schema.prop(this,'NumSections','mxArray');

    schema.prop(this,'SectionOrder','mxArray');

    schema.prop(this,'ScaleValues','mxArray');

    p=schema.prop(this,'OptimizeScaleValues','bool');
    set(p,'FactoryValue',true);

    schema.prop(this,'RoundMode','rmodetype');

    p=schema.prop(this,'OverflowMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(this,'ScaleSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'NumCoeffSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'DenCoeffSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'NumProdSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'DenProdSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'NumAccumSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'DenAccumSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'scalePort','bool');
    set(p,'FactoryValue',false);


