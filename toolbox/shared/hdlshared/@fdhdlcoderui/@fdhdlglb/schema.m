function schema







    mlock;

    pk=findpackage('hdlcoderui');
    parentcls=findclass(pk,'abstracthdlglblsettings');
    pk=findpackage('fdhdlcoderui');
    c=schema.class(pk,'fdhdlglb',parentcls);

    p=schema.prop(c,'ActiveTab','int');
    set(p,'FactoryValue',0,'Visible','off');

    if isempty(findtype('InputComplexityType')),
        schema.EnumType('InputComplexityType',{'Real','Complex'});
    end

    p=schema.prop(c,'InputComplex','InputComplexityType');
    p.AccessFlags.Serialize='off';
    set(p,'Visible','off');

    if isempty(findtype('UIFilterResetTypeEnum')),
        schema.EnumType('UIFilterResetTypeEnum',{'None','Shift register'});
    end
    schema.prop(c,'RemoveResetFrom','UIFilterResetTypeEnum');

    p=schema.prop(c,'InputComplex_bk','ustring');
    set(p,'FactoryValue','','Visible','off');










    m=schema.method(c,'help');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle'};
    s.OutputTypes={};

    m=schema.method(c,'getparam');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle'};

    m=schema.method(c,'dialogCallback');
    s=m.Signature;
    s.varargin='on';
    s.InputTypes={'handle','handle','handle','string','handle','mxArray','mxArray'};
    s.OutputTypes={'bool','string'};

    m=schema.method(c,'selectComboboxEntry');
    s=m.Signature;
    s.varargin='off';
    s.InputTypes={'handle','handle','mxArray','string','mxArray'};


