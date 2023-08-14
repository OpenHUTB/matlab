function schema





    pk=findpackage('sigcodegen');
    c=schema.class(pk,'mcodebuffer',pk.findclass('codebuffer'));

    m=schema.method(c,'read','static');
    set(m.Signature,'Varargin','off',...
    'OutputTypes',{'sigcodegen.mcodebuffer'},...
    'InputTypes',{'ustring'});


