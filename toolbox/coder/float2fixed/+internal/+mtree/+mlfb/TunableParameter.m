




classdef TunableParameter<internal.mtree.mlfb.ChartData
    properties
DataID
    end

    methods
        function this=TunableParameter(name,type,dataID)
            this=this@internal.mtree.mlfb.ChartData(name,type,'parameter');
            this.DataID=dataID;
        end
    end
end
