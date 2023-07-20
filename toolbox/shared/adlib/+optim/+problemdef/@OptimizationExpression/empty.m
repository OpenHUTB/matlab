function eout=empty(varargin)







    if nargin==0
        szVec=[0,0];
    else
        szVec=zeros(varargin{:});
        if numel(szVec)~=0
            error(message('MATLAB:class:emptyMustBeZero'));
        end
        szVec=size(szVec);
    end

    eout=optim.problemdef.OptimizationExpression(szVec,{{},{}});