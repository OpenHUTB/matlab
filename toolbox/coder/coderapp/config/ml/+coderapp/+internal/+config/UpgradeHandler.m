classdef(Abstract)UpgradeHandler<handle&matlab.mixin.Heterogeneous





    methods(Abstract)


        upgrade(this,configStore)



        downgrade(this,configStore,targetVer)
    end
end