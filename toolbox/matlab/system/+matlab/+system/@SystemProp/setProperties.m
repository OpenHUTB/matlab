function setProperties(obj,narg,varargin)


























    if(nargin>1)&&(narg>0)&&~isempty(varargin)




        if matlab.system.isSystemObject(varargin{1})
            matlab.system.internal.error('MATLAB:system:invalidConstructorFirstArgument');
        end

        if narg>length(varargin)
            matlab.system.internal.error('MATLAB:system:invalidSetPropertiesSyntax');
        end

        args=varargin(1:narg);

        if(numel(varargin)==(narg+1))&&isstring(varargin{narg+1})

            valueOnly=cellstr(varargin{narg+1});
        else
            valueOnly=varargin(narg+1:end);
        end

        try
            inactiveProps=parseInputs(obj,args,valueOnly);
        catch me
            throwAsCaller(me);
        end

        if~isempty(inactiveProps)&&...
            ~matlab.system.internal.InactiveWarningSuppressor.isSuppressed(obj)
            for propName=inactiveProps(:)'
                warning(message('MATLAB:system:nonRelevantProperty',propName));
            end
        end
    end
end
