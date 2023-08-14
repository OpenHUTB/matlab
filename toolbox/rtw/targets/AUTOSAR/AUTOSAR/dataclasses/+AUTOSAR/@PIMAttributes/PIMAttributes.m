classdef PIMAttributes<Simulink.CustomStorageClassAttributes




    properties(PropertyType='logical scalar')
        needsNVRAMAccess=false;
        IsArTypedPerInstanceMemory=false;
    end

    methods

        function obj=PIMAttributes()
            mlock;
        end
    end

end
