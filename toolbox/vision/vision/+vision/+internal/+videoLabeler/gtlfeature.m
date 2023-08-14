function flag=gtlfeature(featureName,varargin)










































mlock
    persistent featureVal_Multi featureVal_Debug

    if isempty(featureVal_Multi)
        featureVal_Multi='on';
    end

    if isempty(featureVal_Debug)
        featureVal_Debug='off';
    end

    narginchk(1,2);
    validatestring(lower(featureName),{'multisignalsupport','debug'},...
    mfilename,'Feature Name');

    if nargin==2
        val=varargin{1};
        validatestring(lower(val),{'on','off'});
    end

    switch lower(featureName)
    case 'multisignalsupport'
        if nargin==2
            featureVal_Multi=val;
        end

        flag=featureVal_Multi;
    case 'debug'
        if nargin==2
            featureVal_Debug=val;
        end
        flag=featureVal_Debug;
    otherwise
        error('Unsupported feature control keyword');
    end

end