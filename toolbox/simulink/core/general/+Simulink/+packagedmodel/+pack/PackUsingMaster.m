classdef PackUsingMaster<Simulink.packagedmodel.pack.PackHandler




    methods(Access=protected)
        function process(this)
            for i=1:length(this.SlxcMasterData)
                data=this.prepareData(i);
                this.Results{i}=Simulink.packagedmodel.pack.PackHandler.loc_parPackSLCache(data);
            end
        end

        function data=prepareData(this,i)
            data=this.SlxcMasterData(i);
        end
    end
end
