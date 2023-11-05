function out=generics(varargin)

    for i=1:3:length(varargin)
        out.(varargin{i}).Name=varargin{i};

        out.(varargin{i}).Type=varargin{i+1};
        out.(varargin{i}).default_Value=varargin{i+2};
    end
end

