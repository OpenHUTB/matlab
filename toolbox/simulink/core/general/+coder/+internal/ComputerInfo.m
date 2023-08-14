classdef ComputerInfo<coder.internal.interfaces.IComputerInfo




    methods
        function value=getTotalPhysicalMemory(~)


            [~,mem]=memory();
            value=mem.PhysicalMemory.Total;
        end

        function value=getArchitecture(~)


            value=computer;
        end
    end
end

