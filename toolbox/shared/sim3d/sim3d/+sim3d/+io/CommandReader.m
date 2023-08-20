classdef CommandReader<handle

    properties
        Reader=[]
        Timeout(1,1)int32=120000
    end


    properties(Constant=true)
        Topic='Simulation3DEngineStatus'
        LeaseDuration=10000
    end


    methods

        function self=CommandReader()
            self.Reader=sim3d.io.Subscriber(sim3d.io.CommandReader.Topic,'LeaseDuration',sim3d.io.CommandReader.LeaseDuration);
        end


        function delete(self)
            if~isempty(self.Reader)
                self.Reader.delete();
            end
        end

        function[status,errorCode]=read(self,varargin)
            narginchk(1,2);
            if nargin>1
                errorMessage=varargin{1};
            else
                errorMessage=true;
            end
            if~isempty(self.Reader)
                errorCode=sim3d.engine.EngineReturnCode.OK;
                status=self.Reader.receive(self.Timeout);
                if isempty(status)
                    if self.Reader.Listener.IsPublisherDisconnected
                        errorCode=sim3d.engine.EngineReturnCode.Precondition_Not_Met;
                        if errorMessage
                            exception=MException('sim3d:CommandReader:CommandReader:ReadError',...
                            '3D Simulation engine was terminated by the user (error code: %d).',errorCode);
                            throw(exception);
                        end
                    else
                        errorCode=sim3d.engine.EngineReturnCode.Timeout;
                        if errorMessage
                            exception=MException('sim3d:CommandReader:CommandReader:ReadError',...
                            '3D Simulation engine interface read error');
                            throw(exception);
                        end
                    end
                end
            end
        end


        function setTimeout(self,timeout)
            self.Timeout=1000*timeout;
        end

    end
end
