function g=powergain(sobj,varargin)




    narginchk(1,4)

    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end


    if(nargin>1)&&...
        (isequal(varargin{end},'Gmag')||isequal(varargin{end},'Gmsg'))
        g=powergain(sobj.Parameters,varargin{:});
    else
        g=powergain(sobj.Parameters,sobj.Impedance,varargin{:});
    end