classdef(ConstructOnLoad)MWChIfTX<eda.internal.component.WhiteBox








    properties
dclk
reset
dataOut
dataOutVld

dataIn
dataInVld
txPayLoad


        generic=generics('OUTPUT_DATAWIDTH','integer','8');

    end

    methods
        function this=MWChIfTX(varargin)
            this.setGenerics(varargin);
            this.dclk=eda.internal.component.ClockPort;
            this.reset=eda.internal.component.ResetPort;
            this.dataOut=eda.internal.component.Outport('FiType','uint8');
            this.dataOutVld=eda.internal.component.Outport('FiType','boolean');
            this.dataIn=eda.internal.component.Inport('FiType',this.generic.OUTPUT_DATAWIDTH);
            this.dataInVld=eda.internal.component.Inport('FiType','boolean');
            this.txPayLoad=eda.internal.component.Inport('FiType','boolean');
            this.flatten=false;
        end
    end
end


