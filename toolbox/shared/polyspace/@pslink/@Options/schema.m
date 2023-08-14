

function schema


    hPkg=findpackage('pslink');


    findclass(findpackage('pslink'),'ConfigComp');
    hThisCls=schema.class(hPkg,'Options');


    if isempty(findtype('EnumCoderKind'))
        schema.EnumType('EnumCoderKind',{'unknown','tl','ec','codegen','sfcn','slcc'});
    end


    hProp=schema.prop(hThisCls,'pslinkccListeners','handle.listener vector');
    hProp.AccessFlags.PublicGet='off';
    hProp.AccessFlags.PublicSet='off';
    hProp.AccessFlags.Serialize='off';
    hProp.Visible='off';
    hProp.FactoryValue=[];

    hProp=schema.prop(hThisCls,'pslinkcc','pslink.ConfigComp');
    hProp.AccessFlags.PublicSet='on';
    hProp.AccessFlags.PublicGet='on';
    hProp.Visible='off';
    hProp.AccessFlags.Serialize='off';

    hProp=schema.prop(hThisCls,'coderKind','EnumCoderKind');
    hProp.AccessFlags.PublicSet='off';
    hProp.AccessFlags.PublicGet='on';
    hProp.Visible='off';
    hProp.FactoryValue='unknown';


    hMethod=schema.method(hThisCls,'constructObject');
    hSign=hMethod.Signature;
    hSign.varargin='on';


