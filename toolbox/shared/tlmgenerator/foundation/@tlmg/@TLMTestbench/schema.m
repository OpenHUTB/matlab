function schema




    pkg=findpackage('tlmg');
    findclass(pkg,'SimulinkConnection');
    this=schema.class(pkg,'TLMTestbench');

    schema.prop(this,'ModelConnection','tlmg.SimulinkConnection');






    schema.prop(this,'OrigSllog','mxArray');

    p=schema.prop(this,'OrigSllogName','string');
    p.FactoryValue='tlmg_origsllog';


    schema.prop(this,'SllogBasePath','string');
    p=schema.prop(this,'OutLogNamePrefix','string');
    p.FactoryValue='tlmg_out';
    p=schema.prop(this,'InLogNamePrefix','string');
    p.FactoryValue='tlmg_in';

    schema.prop(this,'TlmInVec','mxArray');
    p=schema.prop(this,'TlmInVecName','string');
    p.FactoryValue='tlmg_tlminvec';

    schema.prop(this,'TlmOutVec','mxArray');
    p=schema.prop(this,'TlmOutVecName','string');
    p.FactoryValue='tlmg_tlmoutvec';

    schema.prop(this,'TlmSllog','mxArray');
    p=schema.prop(this,'TlmSllogName','string');
    p.FactoryValue='tlmg_tlmsllog';





    schema.prop(this,'OutportNameList','string vector');
    schema.prop(this,'InportNameList','string vector');
    schema.prop(this,'VectorPortNameMap','mxArray');

    p=schema.prop(this,'OutportSnk','mxArray');
    p.AccessFlags.AbortSet='off';

    p=schema.prop(this,'InportSrc','mxArray');
    p.AccessFlags.AbortSet='off';


