classdef(Hidden=true)TCPIPHostLauncher<rtw.connectivity.HostLauncher















    properties
        OriginalExtModeMexArgs;
        ExtModeTargetAddress;
        ExtModeVerbosity;
        ExtModePortId;
        ExtModeAdditionalTokens;
        ModelName;
        ExtModeConnectionEnabled;
    end

    methods

        function this=TCPIPHostLauncher(componentArgs)
            narginchk(1,1);


            this@rtw.connectivity.HostLauncher(componentArgs);

            this.ModelName=componentArgs.getModelName();


            this.ExtModeConnectionEnabled=false;


            this.saveExtModeArgs();



            argsString=sprintf('-port %d',this.ExtModePortId);
            this.setArgString(argsString);
        end


        function delete(this)

            this.OriginalExtModeMexArgs=[];
        end

        function extModeEnable(this,enableConnection)






            saveOriginalConfigRequest=~this.ExtModeConnectionEnabled&&...
            enableConnection;

            restoreOriginalConfigRequest=this.ExtModeConnectionEnabled&&...
            ~enableConnection;

            this.ExtModeConnectionEnabled=enableConnection;

            cs=getActiveConfigSet(this.ModelName);
            assert(~isempty(cs)&&~isa(cs,'Simulink.ConfigSetRef'),'invalid config set');

            if this.ExtModeConnectionEnabled
                if saveOriginalConfigRequest






                    this.saveExtModeArgs();



                    if~strcmp(this.ExtModeTargetAddress,'localhost')&&...
                        ~startsWith(this.ExtModeTargetAddress,'127.')


                        MSLDiagnostic('Simulink:Extmode:DefaultHostBasedTargetRunsOnHostPC').reportAsWarning;

                        this.ExtModeTargetAddress='localhost';
                    end
                end

                status=this.getApplicationStatus();

                if(status==rtw.connectivity.LauncherApplicationStatus.RUNNING)
                    if this.ExtModePortId==0

                        serverPort=rtw.connectivity.HostTCPIPCommunicator.parseOutputFileForServerPort(this);
                    else

                        serverPort=this.ExtModePortId;
                    end


                    extModeMexArgs=['''',this.ExtModeTargetAddress,''' ',...
                    this.ExtModeVerbosity,' ',...
                    num2str(serverPort)];




                    extModeMexArgs=[extModeMexArgs,this.ExtModeAdditionalTokens];

                    set_param(cs,'ExtModeMexArgs',extModeMexArgs);
                end
            else
                if restoreOriginalConfigRequest
                    set_param(cs,'ExtModeMexArgs',this.OriginalExtModeMexArgs);
                end
            end
        end
    end

    methods(Access=private)
        function saveExtModeArgs(this)



            this.OriginalExtModeMexArgs=get_param(this.ModelName,'ExtModeMexArgs');

            cs=getActiveConfigSet(this.ModelName);
            assert(~isempty(cs)&&~isa(cs,'Simulink.ConfigSetRef'),'invalid config set');

            idx=get_param(this.ModelName,'ExtModeTransport');
            transport=Simulink.ExtMode.Transports.getExtModeTransport(cs,idx);





            anchorFolder='';
            connectionParams=coder.internal.xcp.parseExtModeArgs(this.OriginalExtModeMexArgs,...
            transport,this.ModelName,anchorFolder);

            tokens=coder.internal.xcp.tokenizeArgsString(this.OriginalExtModeMexArgs);
            targetPortExplicitlySet=(numel(tokens)>2);

            if isempty(connectionParams.targetName)||...
                strcmp(connectionParams.targetName,'[]')
                this.ExtModeTargetAddress='localhost';
            else
                this.ExtModeTargetAddress=connectionParams.targetName;
            end

            this.ExtModeVerbosity=num2str(connectionParams.verbosityLevel);
            if~targetPortExplicitlySet

                this.ExtModePortId=0;
            else
                this.ExtModePortId=connectionParams.targetPort;
            end

            this.ExtModeAdditionalTokens='';
            if numel(tokens)>3



                for i=4:numel(tokens)
                    this.ExtModeAdditionalTokens=[this.ExtModeAdditionalTokens,...
                    ' ',tokens{i}{1}];
                end
            end
        end
    end
end
