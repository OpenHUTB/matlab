function outstr=makehelplinkstr(instr1,varargin)

    if nargin>1
        instr2=varargin{1};
    else
        instr2=instr1;
    end

    if feature('hotlinks')
        outstr=sprintf('<a href="matlab:helpPopup %s">%s</a>',instr1,instr2);
    else
        outstr=instr1;
    end
