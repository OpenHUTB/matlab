classdef(Abstract)IComputerInfo<handle




    methods(Abstract)
        value=getTotalPhysicalMemory(~);
        value=getArchitecture(~);
    end
end

