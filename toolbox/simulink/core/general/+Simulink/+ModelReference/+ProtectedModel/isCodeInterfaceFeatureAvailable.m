function isSupported=isCodeInterfaceFeatureAvailable(modelName,varargin)



    modelName=convertStringsToChars(modelName);

    if nargin>1
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if nargin==2
        isERTTarget=strcmp(varargin{1},'on');
    else
        isERTTarget=strcmp(get_param(modelName,'IsERTTarget'),'on');
    end
    isSupported=builtin('license','test','RTW_Embedded_Coder')&&isERTTarget;

