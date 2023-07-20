function schema








    mlock;


    pir_udd;
    parentPkg=findpackage('hdlcoder');
    parent=findclass(parentPkg,'HDLImplementationM');
    findclass(parentPkg,'network');
    findclass(parentPkg,'component');


    package=findpackage('hdlbuiltinimpl');
    this=schema.class(package,'HDLDirectCodeGen',parent);


    if isempty(findtype('HDLCodeGenMode')),
        schema.EnumType('HDLCodeGenMode',...
        {'emission','instantiation'});

    end




    if isempty(findtype('HDLEmissionHandleType')),
        schema.EnumType('HDLEmissionHandleType',...
        {...
        'useslhandle',...
        'usecomphandle',...
        'useobjandcomphandles',...
        });
    end


    m=schema.method(this,'getBlocks');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(this,'getDescription');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={'MATLAB array'};

    m=schema.method(this,'elaborate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','hdlcoder.network','hdlcoder.component'};
    s.OutputTypes={};


    p=schema.prop(this,'CodeGenFunction','mxArray');
    p.FactoryValue='emit';

    p=schema.prop(this,'FirstParam','HDLEmissionHandleType');
    p.FactoryValue='useobjandcomphandles';

    p=schema.prop(this,'CodeGenParams','mxArray');
    p.FactoryValue=[];

    p=schema.prop(this,'validateFunction','mxArray');
    p.FactoryValue='validate';

    p=schema.prop(this,'validateParams','mxArray');
    p.FactoryValue={};

    schema.prop(this,'Blocks','string vector');
    schema.prop(this,'Description','mxArray');

    p=schema.prop(this,'CodeGenMode','HDLCodeGenMode');
    p.FactoryValue='emission';

    p=schema.prop(this,'generateSLBlockFunction','mxArray');
    p.FactoryValue='generateSLBlock';


    p=schema.prop(this,'implParamInfo','mxArray');
    p.FactoryValue={};


    p=schema.prop(this,'implParams','mxArray');
    p.FactoryValue={};

    p=schema.prop(this,'blkParams','mxArray');
    p.FactoryValue={};

    p=schema.prop(this,'publishImpl','mxArray');
    p.FactoryValue=true;



    p=schema.prop(this,'ArchitectureNames','string vector');
    p.FactoryValue={};



    p=schema.prop(this,'DeprecatedArchName','string vector');
    p.FactoryValue={};

    p=schema.prop(this,'Deprecates','string vector');
    p.FactoryValue={};

    p=schema.prop(this,'Hidden','mxArray');
    p.FactoryValue=false;
