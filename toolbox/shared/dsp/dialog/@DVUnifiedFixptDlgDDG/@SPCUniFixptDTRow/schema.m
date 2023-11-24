function schema
    dspdialogPackage=findpackage('dvdialog');
    findclass(dspdialogPackage,'DSPDDG');

    package=findpackage('DVUnifiedFixptDlgDDG');
    this=schema.class(package,'SPCUniFixptDTRow');

    schema.prop(this,'Block','handle');
    schema.prop(this,'Name','ustring');
    schema.prop(this,'Prefix','ustring');
    schema.prop(this,'Row','int');
    p=schema.prop(this,'Visible','bool');
    p.FactoryValue=1;
    p=schema.prop(this,'SignedSignedness','bool');
    p.FactoryValue=1;
    p=schema.prop(this,'UnsignedSignedness','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'AutoSignedness','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'BinaryPointScaling','bool');
    p.FactoryValue=1;
    p=schema.prop(this,'BestPrecisionMode','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritInternalRule','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritSameWLAsInput','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritInput','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritFirstInput','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritSecondInput','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritProdOutput','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'InheritAccumulator','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'HasDesignMin','bool');
    p.FactoryValue=0;
    p=schema.prop(this,'HasDesignMax','bool');
    p.FactoryValue=0;



    schema.prop(this,'DataTypeStr','ustring');
    schema.prop(this,'DesignMin','ustring');
    schema.prop(this,'DesignMax','ustring');
    schema.prop(this,'ValBestPrecFLMaskPrm','ustring');
    schema.prop(this,'Controller','dvdialog.DSPDDG');


