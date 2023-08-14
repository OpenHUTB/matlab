function h=FcnDefault(varargin)





    h=RTW.FcnDefault;

    if nargin==2
        if isempty(varargin{1})
            h.Name='Auto';
        else
            h.Name=varargin{1};
        end

        h.ModelHandle=varargin{2};
    end

    if h.ModelHandle
        modelName=get_param(h.ModelHandle,'Name');
    else
        modelName='DefaultBlockDiagram';
    end
    h.FunctionName=[modelName,'_step'];
    h.InitFunctionName=[modelName,'_initialize'];
    h.PreConfigFlag=false;
    h.Description=DAStudio.message('RTW:fcnClass:fcnAutoMessage');
    h.Multirate=false;
