



function schema


    hPkg=findpackage('pslink');
    hSuperCls=findclass(findpackage('DAStudio'),'Object');


    hThisCls=schema.class(hPkg,'BlockAnnotation',hSuperCls);


    if isempty(findtype('PSEnumAnnotationType'))
        schema.EnumType('PSEnumAnnotationType',...
        {'Check','Defect','MISRA-C','MISRA-AC-AGC','MISRA-C-2012',...
        'MISRA-C++','JSF','ISO-17961','CERT-C','CERT-CPP',...
        'AUTOSAR-CPP14','GUIDELINES','CUSTOM'});
    end

    if isempty(findtype('PSEnumStatus'))
        schema.EnumType('PSEnumStatus',pslinkprivate('getAnnotationValues','status'));
    end

    if isempty(findtype('PSEnumClassification'))
        schema.EnumType('PSEnumClassification',pslinkprivate('getAnnotationValues','class'));
    end


    hProp=schema.prop(hThisCls,'Block','mxArray');
    hProp.Visible='off';
    hProp.FactoryValue=[];
    hProp.AccessFlags.Serialize='off';

    hProp=schema.prop(hThisCls,'PSAnnotationType','PSEnumAnnotationType');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSAnnotationKind','string');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSOnlyOneCheck','bool');
    hProp.Visible='on';
    hProp.FactoryValue=true;

    hProp=schema.prop(hThisCls,'PSStatus','PSEnumStatus');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSClassification','PSEnumClassification');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'PSComment','string');
    hProp.Visible='on';

    hProp=schema.prop(hThisCls,'listeners','mxArray');
    hProp.Visible='off';
    hProp.FactoryValue=[];
    hProp.AccessFlags.PublicSet='on';
    hProp.AccessFlags.PublicGet='on';
    hProp.AccessFlags.Serialize='off';


    hMethod=schema.method(hThisCls,'getDialogSchema');
    hSig=hMethod.Signature;
    hSig.varargin='off';
    hSig.InputTypes={'handle','string'};
    hSig.OutputTypes={'mxArray'};


    hMethod=schema.method(hThisCls,'dialogControl','static');
    hSign=hMethod.Signature;
    hSign.varargin='on';
    hSign.InputTypes={'handle','handle','mxArray'};
    hSign.OutputTypes={'bool','string'};

    hMethod=schema.method(hThisCls,'isDialogOpened','static');
    hSign=hMethod.Signature;
    hSign.varargin='on';
    hSign.InputTypes={'string'};
    hSign.OutputTypes={'bool'};



