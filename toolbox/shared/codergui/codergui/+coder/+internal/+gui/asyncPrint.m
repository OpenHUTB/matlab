function asyncPrint(obj,varargin)



    validateattributes(obj,{'MException','char','double'},{});

    if~coder.internal.gui.debugmode
        return;
    end

    try
        if isa(obj,'MException')
            com.mathworks.toolbox.coder.util.InternalUtilities.asyncPrintError(obj.getReport());
        else
            text=obj;
            if ischar(obj)&&numel(varargin)>0
                text=sprintf(text,varargin{:});
            end
            com.mathworks.toolbox.coder.util.InternalUtilities.asyncFeval(...
            'fprintf',{'%s\n',text});
        end
    catch me
        if coder.internal.gui.debugmode
            rethrow(me);
        end
    end
end