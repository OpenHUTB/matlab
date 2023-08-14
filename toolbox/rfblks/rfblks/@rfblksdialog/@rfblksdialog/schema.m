function schema






    hDeriveFromPackage=findpackage('Simulink');
    hDeriveFromClass=findclass(hDeriveFromPackage,'SLDialogSource');
    hCreateInPackage=findpackage('rfblksdialog');


    hThisClass=schema.class(hCreateInPackage,'rfblksdialog',hDeriveFromClass);



    p=schema.prop(hThisClass,'Block','mxArray');
    p.SetFunction=@setBlock;

    schema.prop(hThisClass,'Root','mxArray');


    m=schema.method(hThisClass,'rfblksbrowsefile');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'rfblksstoreopcondition');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','mxArray'};
    s.OutputTypes={};

    m=schema.method(hThisClass,'rfblksstoreplotcontrol');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','string','mxArray'};
    s.OutputTypes={};

