function h=ModelSpecificCPrototype(varargin)









    if nargin>0
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    h=RTW.ModelSpecificCPrototype;

    if nargin==2
        if isempty(varargin{1})
            h.Name='ModelspecificCprototype';
        else
            h.Name=varargin{1};
        end

        h.ModelHandle=varargin{2};
        h.FunctionName=[get_param(h.ModelHandle,'Name'),'_custom'];
        h.InitFunctionName=[get_param(h.ModelHandle,'Name'),'_initialize'];
    end

    h.selRow=0;
    h.PreConfigFlag=false;
    h.Description=DAStudio.message('RTW:fcnClass:modelspecificdescription');
