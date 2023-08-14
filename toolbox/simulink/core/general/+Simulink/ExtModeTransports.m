classdef ExtModeTransports<handle





    properties(Access='private')
        Targets string=string.empty;
        Transports string=string.empty;
        MexFiles string=string.empty;
        Interfaces string=string.empty;
        RequiresHardwareBoard logical=logical.empty;
    end

    properties(Constant)
        Instance=Simulink.ExtModeTransports();
    end

    methods
        function obj=ExtModeTransports



            mlock;
        end


        function add(this,sysTargFile,transport,mexfile,...
            interface,requiresHardwareBoard)
            narginchk(5,6);
            if nargin<6




                requiresHardwareBoard=false;
            end

            this.Targets(end+1)=sysTargFile;
            this.Transports(end+1)=transport;
            this.MexFiles(end+1)=mexfile;
            this.Interfaces(end+1)=interface;
            this.RequiresHardwareBoard(end+1)=requiresHardwareBoard;
        end


        function[targets,...
            transports,...
            mexfiles,...
            interfaces,...
            requiresHardwareBoard]=get(this)
            targets=this.Targets;
            transports=this.Transports;
            mexfiles=this.MexFiles;
            interfaces=this.Interfaces;
            requiresHardwareBoard=this.RequiresHardwareBoard;
        end


        function clear(this)
            this.Targets=string.empty;
            this.Transports=string.empty;
            this.MexFiles=string.empty;
            this.Interfaces=string.empty;
            this.RequiresHardwareBoard=logical.empty;
        end
    end

    methods(Static=true)
        function obj=getInstance()
            obj=Simulink.ExtModeTransports.Instance;
        end

        function AddExtModeTransportsImpl(inputs)
            Simulink.ExtModeTransports.Instance.add(...
            inputs{1},inputs{2},inputs{3},inputs{4},inputs{5});
        end
    end
end
