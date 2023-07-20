classdef slhcHDLConnectivityDirector<hdlconnectivity.abstractHDLConnectivityDirector














    properties




        pathUtil;
    end


    methods



        function this=slhcHDLConnectivityDirector(varargin)
            for ii=1:2:numel(varargin)-1,
                this.(varargin{ii})=varargin{ii+1};
            end


            this.adapter_list.FDHC=hdlconnectivity.HDLConnBuilderFDHCAdapter('builder',this.builder);
            this.adapter_list.Direct_Emit=hdlconnectivity.HDLConnBuilderDEsignalAdapter('builder',this.builder);
            this.adapter_list.CGIR=hdlconnectivity.HDLConnBuilderDEsignalAdapter('builder',this.builder);
            this.adapter_list.String=hdlconnectivity.HDLConnBuilderStringAdapter('builder',this.builder);

            this.addChildren(this.adapter_list.FDHC);
            this.addChildren(this.adapter_list.Direct_Emit);
            this.addChildren(this.adapter_list.CGIR);
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






        function setPathUtil(this,pUtil)

            if~isempty(this.pathUtil)
                disconnect(this.pathUtil);
                delete(this.pathUtil);
            end
            this.pathUtil=pUtil;
            this.addChildren(this.pathUtil);


            delim=pUtil.getPathDelim;
            this.setPathDelim(delim);

        end

        function pU=getPathUtil(this)
            pU=this.pathUtil;
        end

        function hpath=getNetworkHDLPath(this,hN)
            hpath=this.pathUtil.getNetworkHDLPath(hN);
        end

        function hpath=getComponentHDLPath(this,cmp)
            hpath=this.pathUtil.getComponentHDLPath(cmp);
        end



    end


    methods(Access=private)
        function adptr=getCurrentAdapter(this)

            adptr=this.adapter_list.(this.current_adapter);
        end

    end







end


