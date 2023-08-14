


classdef Process<handle
    properties(Access=private,Constant=true)
        PROCESS_SPAWN=1;
        PROCESS_READ_AVAILABLE_OUTPUT=2;
        PROCESS_GET_EXIT_STATUS=3;
        PROCESS_KILL=4;
        PROCESS_GET_ENVIRONMENT=5;
    end

    properties(Access=private)
pid
exitStatus
outStr
    end

    methods(Access=public,Static=true)
        function envVars=getEnvironment()


            envVars=process_mex(polyspace.internal.Process.PROCESS_GET_ENVIRONMENT);
        end
    end

    methods(Access=public)
        function this=Process(varargin)
            this.pid=process_mex(polyspace.internal.Process.PROCESS_SPAWN,...
            varargin{:});
            this.exitStatus=NaN;
            this.outStr='';
        end

        function delete(this)
            if~isempty(this.pid)
                this.kill();
                this.getExitStatus();
            end
        end

        function outStr=readAvailableOutput(this)
            outStr=process_mex(polyspace.internal.Process.PROCESS_READ_AVAILABLE_OUTPUT,...
            this.pid);
        end

        function varargout=getExitStatus(this,noHang,flushToMATLABConsole)
            if isnan(this.exitStatus)
                if nargin<2
                    noHang=false;
                end
                if nargin<3
                    flushToMATLABConsole=false;
                end
                [this.exitStatus,newOutStr]=...
                process_mex(polyspace.internal.Process.PROCESS_GET_EXIT_STATUS,...
                this.pid,noHang,flushToMATLABConsole);
                this.outStr=[this.outStr,newOutStr];
            end
            varargout{1}=this.exitStatus;
            if nargout>1
                varargout{2}=this.outStr;
                this.outStr='';
            end
        end

        function kill(this)
            if isnan(this.exitStatus)
                process_mex(polyspace.internal.Process.PROCESS_KILL,...
                this.pid);
            end
        end
    end
end
