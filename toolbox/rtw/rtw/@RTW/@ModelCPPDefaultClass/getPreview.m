function signature=getPreview(hSrc,varargin)



    if nargin<2
        DAStudio.error('RTW:fcnClass:functionNotSupported','getPreview','RTW.ModelCPPDefaultClass');
    end

    hParent=varargin{1};

    if~isempty(hSrc.cache)
        targetObj=hSrc.cache;
    else
        targetObj=hSrc;
    end

    if isa(hSrc,'RTW.ModelCPPDefaultClass')
        if hParent.validationStatus&&...
            strcmp(hParent.validationResult,...
            DAStudio.message('RTW:fcnClass:pressValidate'))
            signature=DAStudio.message('RTW:fcnClass:pressValidatePreview');
            return;
        elseif~hParent.validationStatus||...
            (hParent.validationStatus&&...
            ~isempty(hParent.validationResult))
            signature=DAStudio.message('RTW:fcnClass:previewUnavailable');
            return;
        end
    end
    signature=[targetObj.ModelClassName,' :: ',targetObj.FunctionName,'( )'];
