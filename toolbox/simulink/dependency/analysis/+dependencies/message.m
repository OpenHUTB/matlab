function[str,key]=message(key,varargin)






    try
        if~contains(key,':')

            key=['Engine:',key];
        end
        mObj=message(['SimulinkDependencyAnalysis:',key],varargin{:});
        str=mObj.getString();
    catch E
        fprintf('Translation error: %s\n%s\n',key,E.message);
        dbstack;
        rethrow(E);
    end


