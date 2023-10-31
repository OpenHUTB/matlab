classdef CommandWriter < handle

    properties
        Writer = [];
        SampleTime(1, 1)single{ mustBeFinite } = single(-1);  % 当前的采样时间
        State = int32(-1);  % 向虚幻引擎写入数据的状态
    end


    properties (Constant = true)
        Topic = 'Simulation3DEngineCommand';
        LeaseDuration = 0
    end


    methods

        function self = CommandWriter()
            % 向需要引擎发送的命令格式：
            % 状态、采样时间
            command = struct('state', self.getState(), 'sampleTime', self.getSampleTime());
            self.Writer = sim3d.io.Publisher(sim3d.io.CommandWriter.Topic,  ...
                'Packet', command,  ...
                'LeaseDuration', sim3d.io.CommandWriter.LeaseDuration);
        end


        function setSampleTime(self, sampleTime)
            arguments
                self sim3d.io.CommandWriter
                sampleTime( 1, 1 )single{ mustBePositive }
            end
            self.SampleTime = sampleTime;
        end


        function sampleTime = getSampleTime(self)
            sampleTime = self.SampleTime;
        end


        % 设置虚幻引擎的状态：
        % 状态码含义：sim3d.engine.EngineCommands
        function setState(self, state)
            arguments
                self sim3d.io.CommandWriter
                state( 1, 1 )int32
            end
            self.State = state;
        end


        function state = getState(self)
            state = self.State;
        end


        function delete(self)
            if ~isempty(self.Writer)
                self.Writer.delete();
            end
        end


        % 向虚幻引擎写当前采样时刻的状态信息
        function write(self)
            if ~isempty(self.Writer)
                command = struct('state', self.getState(), 'sampleTime', self.getSampleTime());
                self.Writer.send(command);  % 调用sim3d.io.Publisher的send方法
            end
        end

    end

end


