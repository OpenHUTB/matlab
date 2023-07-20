function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'spblkmultiply');

    p=schema.prop(c,'in1','mxArray');
    p=schema.prop(c,'in2','mxArray');
    p=schema.prop(c,'outname','mxArray');
    p=schema.prop(c,'product_sltype','mxArray');
    p=schema.prop(c,'accumulator_sltype','mxArray');
    p=schema.prop(c,'rounding','mxArray');
    p=schema.prop(c,'saturation','mxArray');


    p=schema.prop(c,'out','mxArray');
    p=schema.prop(c,'mult_type','mxArray');


    p=schema.prop(c,'cplx1','mxArray');
    p=schema.prop(c,'cplx2','mxArray');
    p=schema.prop(c,'re1','mxArray');
    p=schema.prop(c,'re2','mxArray');
    p=schema.prop(c,'im1','mxArray');
    p=schema.prop(c,'im2','mxArray');
    p=schema.prop(c,'in1vec','mxArray');
    p=schema.prop(c,'in2vec','mxArray');

    p=schema.prop(c,'hN','mxArray');
    p.FactoryValue=[];

    p=schema.prop(c,'slrate','mxArray');
    p.FactoryValue=-1;