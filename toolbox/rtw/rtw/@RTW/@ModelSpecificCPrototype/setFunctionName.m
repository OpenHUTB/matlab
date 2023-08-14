function setFunctionName(hSrc,fcnName,varargin)












    if nargin==2
        hSrc.FunctionName=fcnName;
    elseif nargin==3
        whichFunction=varargin{1};
        if strcmp(whichFunction,'step')==1
            hSrc.FunctionName=fcnName;
        elseif strcmp(whichFunction,'init')==1
            hSrc.InitFunctionName=fcnName;
        else
            DAStudio.error('RTW:fcnClass:invalidSetFunctionNameFunctionType');
            return;
        end
    else
        DAStudio.error('RTW:fcnClass:invalidSetFunctionNameNumArgs');
        return;
    end
    if hSrc.ModelHandle~=0
        hModel=hSrc.ModelHandle;
        set_param(hModel,'RTWFcnClass',hSrc);
    end
