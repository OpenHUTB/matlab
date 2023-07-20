function out=AvailableValues(obj,varargin)


    if nargin==1
        out=obj.v_AvailableValues;
    else
        if isempty(obj.f_AvailableValues)
            out=obj.v_AvailableValues;
        else
            cs=varargin{1};
            fn=str2func(obj.f_AvailableValues);
            out=fn(cs,obj.Name);
        end
    end
