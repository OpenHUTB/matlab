
classdef fdhcHDLConnectivityDirector<hdlconnectivity.abstractHDLConnectivityDirector



















    properties
    end


    methods



        function this=fdhcHDLConnectivityDirector(varargin)
            for ii=1:2:numel(varargin)-1,
                this.(varargin{ii})=varargin{ii+1};
            end


            this.adapter_list.FDHC=hdlconnectivity.HDLConnBuilderFDHCAdapter('builder',this.builder);
            this.adapter_list.String=hdlconnectivity.HDLConnBuilderStringAdapter('builder',this.builder);

            this.addChildren(this.adapter_list.FDHC);
            this.addChildren(this.adapter_list.String);

        end
    end


    methods


        function setCurrentAdapter(this,adapter_type)

            this.current_adapter=adapter_type;
        end

        function addDriverReceiverPair(this,driver,receiver,varargin)



            adptr=this.getCurrentAdapter;
            adptr.addDriverReceiverPair(driver,receiver,varargin{:});
        end

        function addRegister(this,in,out,clock,clockenable,varargin)


            adptr=this.getCurrentAdapter;
            adptr.addRegister(in,out,clock,clockenable,varargin{:});
        end

        function addDriverReceiverRegistered(this,varargin)

            adptr=this.getCurrentAdapter;
            adptr.addDriverReceiverRegistered(varargin{:});
        end

    end


    methods(Access=private)
        function adptr=getCurrentAdapter(this)

            adptr=this.adapter_list.(this.current_adapter);
        end

    end







end


