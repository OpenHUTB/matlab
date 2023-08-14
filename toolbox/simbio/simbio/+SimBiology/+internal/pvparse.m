function pvstruct=pvparse(knownprops,varargin)



















    nargs=numel(varargin);
    if mod(nargs,2)~=0
        error('SimBiology:PRIVATEPVPARSE_PV_MISMATCH',...
        'Incomplete param/value argument pairs.');
    end

    Npv=nargs/2;
    pvstruct=struct('p',cell(Npv,1),'v',cell(Npv,1));
    for c=1:Npv
        prop=varargin{2*c-1};
        val=varargin{2*c};
        if~ischar(prop)
            error('SimBiology:PRIVATEPVPARSE_BAD_PROP',...
            'Each property name must be a character vector.');
        end

        tf=strcmpi(prop,knownprops);
        if~any(tf)
            error('SimBiology:PRIVATEPVPARSE_UNKNOWN_PROP',...
            'Unknown property ''%s''.',prop);
        end
        pvstruct(c).p=knownprops{tf};
        pvstruct(c).v=val;
    end
