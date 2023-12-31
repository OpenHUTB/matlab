function list=getUnsupportedEMLFunctions



    if slfeature('ExpandedEMLSupport')>0
        list={};
    else
        list={...
        'acos','acosd','acosh','acot','acotd','acoth','acsc','acscd','acsch','angle',...
        'asec','asecd','asech','asin','asind','asinh','atan','atan2','atand','atanh',...
        'beta','betainc','betaln',...
        'cart2pol','cart2sph','char','chol','complex','cond',...
        'cos','cosd','cosh','cot','cotd','coth',...
        'csc','cscd','csch',...
        'det','detrend',...
        'eig','ellipke','erf','erfc','erfcinv','erfcx','erfinv','exp','expint','expm','expm1',...
        'fft','fftshift',...
        'gamma','gammainc','gammaln',...
        'hilb','hypot',...
        'ifft','ifftshift','inv','invhilb','ischar','isstruct',...
        'log','log2','log10','log1p','logspace','lu',...
        'nextpow2','nthroot',...
        'pinv','planerot','pol2cart','poly','polyfit','pow2',...
        'qr',...
        'rand','randn','rank','reallog',...
        'realpow','realsqrt',...
        'sec','secd','sech','sin','sind','sinh',...
        'sosfilt','sph2cart','sqrt','std','struct',...
        'subspace','svd',...
        'tan','tand','tanh','typecast',...
        'rcond'};

        if slavteng('feature','Hisl_0005')
            list(end)=[];
        end
    end
