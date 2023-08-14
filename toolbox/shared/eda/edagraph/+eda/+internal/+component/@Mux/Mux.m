classdef(ConstructOnLoad)Mux<eda.internal.component.WhiteBox







    properties

dsel
din1
din2
dout

        generic=generics('DATA_WIDTH','integer','8');
    end

    methods
        function this=Mux(varargin)
            this.setGenerics(varargin);
            this.dsel=eda.internal.component.Inport('FiType','boolean');
            this.din1=eda.internal.component.Inport('FiType',this.generic.DATA_WIDTH);
            this.din2=eda.internal.component.Inport('FiType',this.generic.DATA_WIDTH);
            this.dout=eda.internal.component.Outport('FiType',this.generic.DATA_WIDTH);
            this.flatten=true;
        end
    end

end

