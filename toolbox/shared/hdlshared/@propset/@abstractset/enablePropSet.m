function enablePropSet(h,varargin)














    if(nargin>1)&&ischar(varargin{1})



        name=varargin{1};
        if nargin<3
            ena=true;
        else
            ena=varargin{2};
        end
        h.prop_set_enables(h.getPropSetIdx(name))=ena;
    else



        if nargin<2
            ena=true;
        else
            ena=varargin{1};
        end
        h.prop_set_enables(:)=ena;
    end


