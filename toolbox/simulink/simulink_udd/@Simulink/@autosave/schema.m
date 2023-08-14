function schema





    tCl=schema.class(findpackage('Simulink'),'autosave');


    p=schema.prop(tCl,'files','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p=schema.prop(tCl,'keeporiginals','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p=schema.prop(tCl,'filedates','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p=schema.prop(tCl,'autodates','MATLAB array');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p=schema.prop(tCl,'filestate','MATLAB array');
    p.AccessFlags.PublicSet='on';
    p.AccessFlags.PublicGet='on';
    p=schema.prop(tCl,'mywindow','handle');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';
    p=schema.prop(tCl,'windowopen','bool');
    p.AccessFlags.PublicSet='off';
    p.AccessFlags.PublicGet='off';


    schema.method(tCl,'restore','static');
    schema.method(tCl,'autosaveext','static');


    m=schema.method(tCl,'apply');
    s=m.Signature;
    s.varargin='off';
    s.OutputTypes={'bool','string'};
    s.InputTypes={'handle'};


    m=schema.method(tCl,'close');
    s=m.Signature;
    s.varargin='off';
    s.OutputTypes={};
    s.InputTypes={'handle'};


    m=schema.method(tCl,'setButtonState');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','mxArray','mxArray','bool'};
    s.OutputTypes={};


    m=schema.method(tCl,'buttonCallback');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={};


    m=schema.method(tCl,'getDialogSchema');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','string'};
    s.OutputTypes={'mxArray'};
