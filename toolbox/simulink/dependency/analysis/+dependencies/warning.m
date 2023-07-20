function warning(key,varargin)




    [msg,key]=dependencies.message(key,varargin{:});
    warning(['SimulinkDependencyAnalysis:',key],'%s',msg);

