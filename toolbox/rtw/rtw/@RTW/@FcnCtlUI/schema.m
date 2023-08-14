function schema




    hCreateInPackage=findpackage('RTW');
    hPackage=findpackage('DAStudio');
    hBaseClass=findclass(hPackage,'Object');

    hThisClass=schema.class(hCreateInPackage,'FcnCtlUI',hBaseClass);


    hThisProp=schema.prop(hThisClass,'fcnclass','handle');
    hThisProp.SetFunction=@setFcnClass;

    schema.prop(hThisClass,'dialogHndl','handle');

    findclass(findpackage('RTW'),'ModelSpecificCPrototype');
    hThisProp=schema.prop(hThisClass,'cachedFcnClass','RTW.FcnCtl');
    hThisProp.AccessFlags.Serialize='off';
    schema.prop(hThisClass,'preFunctionClass','int32');
    schema.prop(hThisClass,'validationStatus','bool');
    schema.prop(hThisClass,'validationResult','string');

    schema.prop(hThisClass,'closeListener','mxArray');



    m=schema.method(hThisClass,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};

    m=schema.method(hThisClass,'preApplyCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={'bool','string'};

    m=schema.method(hThisClass,'closeCB');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'FunctionClassChanged');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','double','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'preConfig');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'validate');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'isHierarchyReadonly');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle'};
    s.OutputTypes={'bool'};

    function newValue=setFcnClass(hThis,valueProposed)
        if~isa(valueProposed,'RTW.FcnCtl')
            newValue=hThis.fcnclass;
            DAStudio.error('RTW:fcnClass:expectingFcnClassType');
        else
            newValue=valueProposed;
        end
