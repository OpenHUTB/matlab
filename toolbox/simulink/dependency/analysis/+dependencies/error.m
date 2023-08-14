function error(key,varargin)




    [msg,key]=dependencies.message(key,varargin{:});
    error(['SimulinkDependencyAnalysis:',key],'%s',msg);

