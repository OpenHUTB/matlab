classdef(CaseInsensitiveProperties,TruncatedProperties)...
    filter<rfbbequiv.rfbbequiv

















    methods
        function h=filter(varargin)












            set(h,'Name','rfbbequiv.filter object',varargin{:});
        end

    end

    methods
        h=analyze(h,block)
        transf=localfreqresp(h,block)
    end

end



