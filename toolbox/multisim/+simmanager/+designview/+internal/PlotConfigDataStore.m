classdef(Abstract)PlotConfigDataStore<handle

    properties(Abstract,Constant)
Config
    end


    methods(Abstract)
        persist(obj,configRegistry)
        configRegistry=load(obj,dataModel)
        clear(obj)
    end

end
