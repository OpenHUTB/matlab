function flag=labelerFeature(featureName,varargin)

































mlock
    persistent skipChecks
    if isempty(skipChecks)
        skipChecks='off';
    end

    narginchk(1,2);
    validateattributes(featureName,{'char'},{},mfilename,'feature name');

    switch lower(featureName)
    case 'skipchecks'

    otherwise
        error('Unsupported feature control keyword');
    end

    if nargin==2

        val=varargin{1};
        validatestring(lower(val),{'on','off'});
        skipChecks=val;
    end

    flag=skipChecks;

end