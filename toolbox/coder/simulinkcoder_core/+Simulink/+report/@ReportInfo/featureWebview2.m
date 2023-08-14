function out=featureWebview2(varargin)



    persistent FLAG

    if isempty(FLAG)

        FLAG=true;
    end

    if(nargin>0)
        FLAG=varargin{1};
    end

    out=FLAG;
