function fcnName=getFunctionName(hSrc,varargin)












    if nargin==1
        fcnName=hSrc.FunctionName;
    elseif nargin==2
        whichFunction=varargin{1};
        if strcmp(whichFunction,'step')==1
            fcnName=hSrc.FunctionName;
        elseif strcmp(whichFunction,'init')==1
            fcnName=hSrc.InitFunctionName;
        else
            DAStudio.error('RTW:fcnClass:invalidGetFunctionNameFunctionType');
            return;
        end
    else
        DAStudio.error('RTW:fcnClass:invalidGetFunctionNameNumArgs');
    end


