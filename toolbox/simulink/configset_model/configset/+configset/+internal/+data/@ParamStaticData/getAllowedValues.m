function out=getAllowedValues(obj,varargin)



    if nargin<2
        avail=obj.AvailableValues;
    else
        avail=obj.AvailableValues(varargin{1});
    end

    if~isempty(avail)
        if isnumeric(avail)
            out=num2cell(avail);
        else
            out={avail.str};
        end
    else
        out={};
    end



