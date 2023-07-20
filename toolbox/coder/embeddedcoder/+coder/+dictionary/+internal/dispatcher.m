
function varargout=dispatcher(fcnName,obj,varargin)
    w=warning('backtrace','off');
    oc=onCleanup(@()warning(w));
    try
        if isa(obj,'coderdictionary.data.AbstractStorageClass')
            [varargout{1:nargout}]=coder.dictionary.internal.StorageClass.(fcnName)(varargin{1:end});
        elseif isa(obj,'coderdictionary.data.AbstractMemorySection')
            [varargout{1:nargout}]=coder.dictionary.internal.MemorySection.(fcnName)(varargin{1:end});
        elseif isa(obj,'coderdictionary.data.FunctionClass')
            [varargout{1:nargout}]=coder.dictionary.internal.FunctionCustomizationTemplate.(fcnName)(varargin{1:end});
        elseif isa(obj,'coderdictionary.data.RuntimeEnvironment')
            [varargout{1:nargout}]=coder.dictionary.internal.RuntimeEnvironment.(fcnName)(varargin{1:end});
        elseif isa(obj,'coderdictionary.data.TimerService')
            [varargout{1:nargout}]=coder.dictionary.internal.TimerService.(fcnName)(varargin{1:end});
        else
            assert(false,'Unrecognized entry type');
        end
    catch me
        throwAsCaller(me);
    end
end

