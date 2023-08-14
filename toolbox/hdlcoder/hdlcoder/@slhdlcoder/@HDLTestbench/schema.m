function schema




    pkg=findpackage('slhdlcoder');
    shpkg=findpackage('hdlshared');
    parent=findclass(shpkg,'AbstractHDLTestBench');
    this=schema.class(pkg,'HDLTestbench',parent);

    schema.prop(this,'ModelConnection','mxArray');


    schema.prop(this,'tbRatesOut','mxArray');


    schema.prop(this,'isIPTestbench','bool');

    p=schema.prop(this,'DUTMdlRefHandle','double');
    p.factoryValue=0;


    schema.prop(this,'CachedSingleTaskRateTransMsg','string');

    p=schema.prop(this,'ScalarizeDUTPorts','double');
    p.factoryValue=0;



    p=schema.prop(this,'resetHoldTime','double');
    p.factoryValue=20;






    p=schema.prop(this,'useFileIO','mxArray');
    p.factoryValue=[];
