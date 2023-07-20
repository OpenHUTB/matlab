classdef(ConstructOnLoad)ROM<eda.internal.component.WhiteBox



    properties
clk
addr


        generic=generics('DATAWIDTH','integer','8',...
        'ADDRWIDTH','integer','8');
ROM_VALUE
        COMPLEXITY=true




    end

    methods
        function this=ROM(varargin)
            this.flatten=false;
            this.COMPLEXITY=varargin{1};
            this.ROM_VALUE=varargin{2};
            this.setGenerics(varargin(3:end));
            this.clk=eda.internal.component.ClockPort;
            this.addr=eda.internal.component.Inport('FiType',this.generic.ADDRWIDTH);
            if this.COMPLEXITY==1
                addprop(this,'dout_re');
                this.dout_re=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
                addprop(this,'dout_im');
                this.dout_im=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
            else
                addprop(this,'dout');
                this.dout=eda.internal.component.Outport('FiType',this.generic.DATAWIDTH);
            end
        end
    end

end

