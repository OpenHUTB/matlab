function compileTimeChecks(model,varargin)




    import coder.dictionary.internal.*;
    termCompilation=compileModelForRTW(model);
    for i=1:length(varargin)
        varargin{i}();
    end
    termCompilation.delete();
end
