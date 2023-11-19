classdef block<wt.internal.uhd.clibgen.node

    properties(Access=protected)
id
ctrl
regs
    end

    properties(SetAccess=private,GetAccess=protected)
graph
    end

    methods(Access=protected)

        function control=getCustomBlockController(obj)
            control=obj.graph.get_block(getID(obj));
        end

    end
    methods
        function obj=block(graph,name,varargin)

            obj=obj@wt.internal.uhd.clibgen.node(name,varargin{:});
            obj.id=clib.wt_uhd.uhd.rfnoc.block_id_t(name);
            obj.graph=graph;
            try
                obj.ctrl=getCustomBlockController(obj);
            catch ME
                error(message('wt:rfnoc:host:BlockNotFound',obj.name));
            end
            obj.regs=obj.ctrl.regs;
        end

        function writeRegister(obj,reg,regVal,varargin)
            if nargin==3
                obj.regs.poke32(reg,regVal);
            else
                obj.ctrl.poke32(reg,regVal,varargin{1});
            end
        end

        function regVal=readRegister(obj,reg,varargin)
            if nargin==2
                regVal=obj.regs.peek32(reg);
            else
                regVal=obj.regs.peek32(reg,varargin{1});
            end
        end
        function writeRegister64(obj,reg,regVal,varargin)
            if nargin==3
                obj.regs.poke64(reg,regVal);
            else
                obj.ctrl.poke64(reg,regVal,varargin{1});
            end
        end

        function regVal=readRegister64(obj,reg,varargin)
            if nargin==2
                regVal=obj.regs.peek64(reg);
            else
                regVal=obj.regs.peek64(reg,varargin{1});
            end
        end

        function setProperty(obj,name,value,varargin)
            narginchk(3,4);
            switch class(value)
            case 'int32'
                setPropFunc=str2func("set_property_int_");
            case 'uint64'
                setPropFunc=str2func("set_property_unsignedLong_");
            case 'logical'
                setPropFunc=str2func("set_property_bool_");
            case 'double'
                setPropFunc=str2func("set_property_double_");
            end
            if nargin==3
                setPropFunc(obj.ctrl,name,value);
            else
                setPropFunc(obj.ctrl,name,value,varargin{1});
            end
        end
        function val=getProperty(obj,dataType,key,varargin)
            narginchk(3,4);
            switch(dataType)
            case 'double'
                getPropFunc=str2func("get_property_double_");
            case 'uint64'
                getPropFunc=str2func("get_property_unsignedLong_");
            case 'logical'
                getPropFunc=str2func("get_property_bool_");
            case 'int32'
                getPropFunc=str2func("get_property_int_");
            otherwise
                error(message("wt:rfnoc:host:UnimplementedType"));
            end
            if nargin==3
                val=getPropFunc(obj.ctrl,key);
            else
                val=getPropFunc(obj.ctrl,key,varargin{1});
            end
        end

        function issueStreamCommand(obj,stream_mode,num_samples,varargin)

            stream_args={stream_mode,num_samples};
            if nargin>4

                stream_args{end+1}=varargin{2};
            end
            stream_cmd=wt.internal.uhd.clibgen.stream.getStreamCommand(stream_args{:});
            args={stream_cmd};
            if nargin>3

                args{end+1}=varargin{1};
            else

                args{end+1}=0;
            end
            obj.ctrl.issue_stream_cmd(args{:});
        end

        function block_ctrl=getControl(obj,varargin)
            block_ctrl=obj.ctrl;
        end

        function block_id=getID(obj,varargin)
            block_id=obj.id;
        end

        function num=getNumInputPorts(obj)
            num=obj.ctrl.get_num_input_ports;
        end

        function num=getNumOutputPorts(obj)
            num=obj.ctrl.get_num_output_ports;
        end
    end

    methods(Hidden)
        function setProperties(obj,addr,varargin)
            property=wt.internal.uhd.clibgen.block.getDeviceAddr(addr);
            obj.ctrl.set_properties(property,varargin{1})
        end
    end

    methods(Static)
        function device_addr=getDeviceAddr(addr)
            device_addr=clib.wt_uhd.uhd.device_addr_t(addr);
        end
    end
end

