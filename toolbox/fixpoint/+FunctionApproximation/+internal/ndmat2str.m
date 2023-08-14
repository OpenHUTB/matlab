function stringValues=ndmat2str(numericValues,varargin)






    mustBeNumericOrLogical(numericValues);

    if ismatrix(numericValues)

        stringValues=mat2str(numericValues,varargin{:});
    else

        stringValues=['reshape(',mat2str(numericValues(:),varargin{:}),',',mat2str(size(numericValues)),')'];
    end
end