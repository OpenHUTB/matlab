function out=getPrompt(obj,varargin)


    narginchk(1,2);
    if nargin==2&&~isempty(obj.UI)&&~isempty(obj.UI.f_prompt)
        cs=varargin{1};
        fn=str2func(obj.UI.f_prompt);
        out=fn(cs,obj.Name);
        return;
    end

    if isempty(obj.Prompt)
        default=obj.Name;

        if isempty(obj.UI)
            out=default;
        else
            if isempty(obj.UI.prompt)
                out='';
            else
                try
                    out=configset.internal.getMessage(obj.UI.prompt);
                catch
                    out=default;
                end
            end
        end
        obj.Prompt=out;
    else
        out=obj.Prompt;
    end

