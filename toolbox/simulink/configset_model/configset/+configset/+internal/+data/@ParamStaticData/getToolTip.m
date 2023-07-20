function out=getToolTip(obj,cs)



    if isempty(obj.ToolTip)
        default='';

        out=default;
        if isempty(obj.UI)

        elseif~isempty(obj.UI.tooltip)
            try
                out=configset.internal.getMessage(obj.UI.tooltip);
            catch

            end
            obj.ToolTip=out;



        elseif~isempty(obj.UI.f_tooltip)&&nargin>1
            fn=str2func(obj.UI.f_tooltip);
            out=fn(cs,obj.Name);
        end
    else
        out=obj.ToolTip;
    end

