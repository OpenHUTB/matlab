



classdef block<wt.internal.uhd.mcos.node
    properties
ctrl
    end

    methods
        function obj=block(blockName,varargin)
            obj=obj@wt.internal.uhd.mcos.node(blockName,varargin);
        end
    end

    methods
        function makeBlock(obj,radio)
            obj.ctrl.setGraph(radio);
            try
                obj.ctrl.setBlock(obj.name);
            catch ME
                error(message('wt:rfnoc:host:BlockNotFound',obj.name));
            end
        end











































        function issueStreamCommand(obj,stream_mode,num_samples,varargin)
            narginchk(3,5)
            args={stream_mode,num_samples};






            if nargin<4
                args{end+1}=0;
                args{end+1}=1;
            elseif nargin<5
                args{end+1}=varargin{1};
                args{end+1}=1;
            else
                args=[args(:)',varargin{1}];
                args{end+1}=2;
            end
            try
                obj.ctrl.issueStreamCommand(args{:});
            catch ME
                rethrow(ME);
            end
        end
        function num=getNumInputPorts(obj)
            num=obj.ctrl.getNumInputPorts();
        end

        function num=getNumOutputPorts(obj)
            num=obj.ctrl.getNumOutputPorts();
        end

        function writeRegister(obj,reg,regVal,varargin)




            narginchk(3,4);
            if nargin>3
                time=varargin{1};
            else
                time=0;
            end
            ack=false;
            obj.ctrl.writeRegister(reg,regVal,time,ack);
        end

        function regVal=readRegister(obj,reg,varargin)




            if nargin<4
                time=0;
            else
                time=varargin{1};
            end
            regVal=obj.ctrl.readRegister(reg,time);
        end





























    end

    methods(Hidden)
        function setProperties(obj,property,varargin)
            if~isempty(varargin)
                instance=varargin{1};
            else
                instance=0;
            end
            obj.ctrl.setProperties(property,instance);
        end
    end
end


