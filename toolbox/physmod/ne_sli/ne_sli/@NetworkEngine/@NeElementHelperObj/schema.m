function schema








    hCreateInPackage=findpackage('NetworkEngine');


    hThisClass=schema.class(hCreateInPackage,'NeElementHelperObj');


    p=schema.prop(hThisClass,'descriptorStr','ustring');
    p=schema.prop(hThisClass,'hElementObj','handle');
    p=schema.prop(hThisClass,'parameterVec','handle vector');
    p=schema.prop(hThisClass,'variableVec','handle vector');
    p=schema.prop(hThisClass,'terminalVec','handle vector');
    p=schema.prop(hThisClass,'inputVec','handle vector');
    p=schema.prop(hThisClass,'outputVec','handle vector');



    p=schema.prop(hThisClass,'portVec','handle vector');


    m=schema.method(hThisClass,'NeElementHelperObj');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'mxArray'};
    s.OutputTypes={'handle'};

