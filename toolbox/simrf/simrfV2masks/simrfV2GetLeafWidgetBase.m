function dlgstruct=simrfV2GetLeafWidgetBase(type,name,tag,sync,prop)



















    narginchk(4,5);

    dlgstruct.Type=type;
    dlgstruct.Tag=tag;
    dlgstruct.Tunable=0;


    if~isempty(name)
        dlgstruct.Name=name;
    end


    if strcmp(type,'text')
        dlgstruct.Mode=false;
    else
        dlgstruct.Mode=true;
    end


    if nargin>=5
        dlgstruct.ObjectProperty=prop;
    end


    if sync~=0
        dlgstruct.MatlabMethod='simrfV2DDGSync';
        dlgstruct.MatlabArgs={sync,'%dialog','%tag'};
    end