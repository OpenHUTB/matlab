classdef HDLConnBuilderFDHCAdapter<hdlconnectivity.HDLConnBuilderDEsignalAdapter







    methods
        function this=HDLConnBuilderFDHCAdapter(varargin)
            for ii=1:2:numel(varargin)-1,
                this.(varargin{ii})=varargin{ii+1};
            end

















        end
    end

    methods





        function tf=signalValidate(this,signal)
            tf=isa(signal,'double');
        end
        function tf=clockValidate(this,clk)
            tf=isa(clk,'double');
        end
        function tf=clockEnableValidate(this,enb)
            tf=isa(enb,'double');
        end


    end

    methods




        function net=netFromSignal(this,signal,pathin,index)%#ok<INUSD>











            if nargin>3&&~isempty(index),
                netname=[hdlsignalname(signal),this.array_deref(1),num2str(index),this.array_deref(2)];
            else
                netname=hdlsignalname(signal);
            end

            paths=this.currentHDLPath;
            sltype=hdlsignalsltype(signal);
            for ii=1:numel(paths)
                net(ii)=hdlconnectivity.hdlnet('name',netname,...
                'path',paths{ii},...
                'sltype',sltype,...
                'PIRSignal',[]...
                );
            end
        end

    end

end




