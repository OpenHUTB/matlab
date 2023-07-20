function N=computechebyorder(e,L)




    nameOfFunction='computechebyorder';
    validateattributes(e,{'numeric'},{'scalar','nonempty','real',...
    'finite','nonnan','positive'},...
    nameOfFunction,'Edge length',1);
    validateattributes(L,{'numeric'},{'scalar','nonempty',...
    'real','finite',...
    'nonnan','positive'},...
    nameOfFunction,'Length',2);

    N=ceil(pi*L/(2*e));
    if isequal(mod(N,2),0)
        N=N+1;
    end