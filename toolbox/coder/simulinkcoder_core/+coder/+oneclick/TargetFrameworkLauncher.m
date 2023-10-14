classdef TargetFrameworkLauncher < coder.oneclick.ILauncher

    properties ( Access = private )
        Board;
        Exe;
        AppExecutionService;
        CommunicationInterfaceArgs;
        VariableExpansion;
        ComponentCodePath;
        Model;
        RootFolder;
        StdOutInd = 0;
        StdErrInd = 0;
    end

    methods
        function this = TargetFrameworkLauncher( model,  ...
                board,  ...
                componentCodePath,  ...
                rootFolder, exe )
            arguments
                model( 1, 1 )string;
                board( 1, 1 )target.internal.Board;
                componentCodePath( 1, 1 )string;
                rootFolder( 1, 1 )string;
                exe( 1, 1 )string;
            end
            this.Model = model;
            this.Board = board;
            this.ComponentCodePath = componentCodePath;
            this.RootFolder = rootFolder;
            this.Exe = exe;

            this.createAppExecutionService;
        end

        function setExe( ~, ~ )
            assert( false,  ...
                'TargetFrameworkLauncher:assert:setExe',  ...
                'Exe must be set once during object construction.' );
        end

        function exe = getExe( this )
            exe = this.Exe;
        end

        function startApplication( this )


            this.AppExecutionService.open;
            this.AppExecutionService.load;
            this.AppExecutionService.start;


            [ ~, command ] = this.getFinalExecutionTool( this.Board );
            if isempty( command )

                allArgs = {  };
            else

                allArgs = command.Arguments;
            end
            allArgs = [ allArgs, this.CommunicationInterfaceArgs ];
            argDisplayString = this.VariableExpansion.expand( strjoin( allArgs, ' ' ) );

            if isempty( command )

                commandDisplayString = this.Exe;
                if ~isempty( argDisplayString )
                    argDisplayString = sprintf( '(%s)', argDisplayString );
                end
            else

                commandDisplayString = this.VariableExpansion.expand( command.String );
            end
            if ~isempty( argDisplayString )
                commandDisplayString = sprintf( '%s %s', commandDisplayString, argDisplayString );
            end

            startMessage = message( 'Simulink:Extmode:StartedExecutable',  ...
                commandDisplayString ).getString;


            startMessage = strrep( startMessage, '$(EXE)', this.Exe );
            Simulink.output.info( startMessage );

            this.showOutputStreams(  ...
                'Simulink:Extmode:TFLauncherStdoutOnStart',  ...
                'Simulink:Extmode:TFLauncherStderrOnStart',  ...
                true );
        end

        function status = getApplicationStatus( this )
            switch this.AppExecutionService.ApplicationStatus
                case target.internal.ApplicationStatus.Running
                    status = rtw.connectivity.LauncherApplicationStatus.RUNNING;

                case target.internal.ApplicationStatus.Stopped
                    status = rtw.connectivity.LauncherApplicationStatus.NOT_RUNNING;

                case target.internal.ApplicationStatus.Unknown
                    status = rtw.connectivity.LauncherApplicationStatus.UNKNOWN;

                otherwise

                    assert( false, 'Unhandled application status' );
            end
        end

        function stopApplication( this )


            this.AppExecutionService.stop;
            this.AppExecutionService.unload;
            this.AppExecutionService.close;

            this.showOutputStreams(  ...
                'Simulink:Extmode:TFLauncherStdoutOnStop',  ...
                'Simulink:Extmode:TFLauncherStderrOnStop',  ...
                false );

            Simulink.output.info(  ...
                sprintf( '%s: %s',  ...
                message( 'Simulink:Extmode:StoppedExecutable' ).getString, this.Exe ) );
        end

        function showOutputStreams( this, stdoutHeader, stderrHeader, reset )
            if reset
                this.StdOutInd = 0;
                this.StdErrInd = 0;
            end

            stdOutStr = this.AppExecutionService.getStandardOutput;
            if numel( stdOutStr ) > this.StdOutInd
                stdoutMessageHeader = message( stdoutHeader );
                Simulink.output.info( ' ' );
                Simulink.output.info( stdoutMessageHeader.getString );
                Simulink.output.info( stdOutStr( this.StdOutInd + 1:end  ) );
                Simulink.output.info( ' ' );
                this.StdOutInd = numel( stdOutStr );
            end

            stdErrStr = this.AppExecutionService.getStandardError;
            if numel( stdErrStr ) > this.StdErrInd
                stderrMessageHeader = message( stderrHeader );
                Simulink.output.info( ' ' );
                Simulink.output.info( stderrMessageHeader.getString );
                Simulink.output.info( stdErrStr( this.StdErrInd + 1:end  ) );
                Simulink.output.info( ' ' );
                this.StdErrInd = numel( stdErrStr );
            end
        end

        function extModeEnable( ~, ~ )



        end

        function componentCodePath = getComponentCodePath( this )
            componentCodePath = this.ComponentCodePath;
        end

        function delete( this )

            if ~isempty( this.AppExecutionService )




                try
                    this.AppExecutionService.release(  );
                catch releaseError







                    if ~strcmp( releaseError.identifier, 'targetframework:AppExecutionService:ReleaseNotSupported' )




                        warning( releaseError.message, releaseError.identifier );
                    end
                end
            end
        end
    end

    methods ( Static )
        function deploymentTool = getDeploymentTool( board )

            deploymentTool = [  ];
            if ~isempty( board.Tools.DeploymentTools )
                deploymentTool = board.Tools.DeploymentTools( 1 );
            end
        end

        function executionTool = getExecutionTool( board )

            executionTool = [  ];
            if ~isempty( board.Tools.ExecutionTools )
                executionTool = board.Tools.ExecutionTools( 1 );
            end
        end

        function [ tool, command ] = getFinalExecutionTool( board )

            tool = [  ];
            command = [  ];
            deploymentTool = coder.oneclick.TargetFrameworkLauncher.getDeploymentTool( board );
            if isempty( deploymentTool ) || ~deploymentTool.ApplicationStartsOnDeployment
                tool = coder.oneclick.TargetFrameworkLauncher.getExecutionTool( board );
                if ~isempty( tool ) && isa( tool, 'target.internal.SystemCommandExecutionTool' )
                    command = tool.StartCommand;
                end
            elseif ~isempty( deploymentTool )
                tool = deploymentTool;
                command = tool.Command;
            end
        end

        function variableExpansion = createVariableExpansion( board,  ...
                exe,  ...
                connectionParams )
            variableExpansion = targetframework.services.variableexpansion.createVariableExpansion(  );

            [ exePath, exeName, exeExt ] = fileparts( exe );
            variableExpansion.define( 'EXE_PATH', exePath );
            variableExpansion.define( 'EXE_NAME', exeName );
            variableExpansion.define( 'EXE_EXT', exeExt );

            if ~isempty( connectionParams )


                switch connectionParams.transport
                    case Simulink.ExtMode.Transports.XCPTCP.Transport

                        communicationChannel = target.internal.create( 'TCPChannel',  ...
                            'IPAddress', connectionParams.targetName,  ...
                            'Port', string( connectionParams.targetPort ) );

                        connectionProperties = target.internal.ConnectionProperties.empty(  );
                    case Simulink.ExtMode.Transports.XCPSerial.Transport

                        communicationChannel = target.internal.create( 'RS232Channel',  ...
                            'BaudRate', connectionParams.baudRate );

                        connectionProperties = target.internal.create( 'Port',  ...
                            'PortNumber', connectionParams.portName );
                    otherwise
                        assert( false, 'Unexpected transport: %s', connectionParams.transport );
                end

                mexArgsConnection = target.internal.create( 'TargetConnection',  ...
                    'CommunicationChannel', communicationChannel );
                mexArgsConnection.Target = board;
                mexArgsConnection.ConnectionProperties = connectionProperties;


                variableExpansion.define( mexArgsConnection );
            end
        end
    end

    methods ( Access = private )
        function communicationInterfaceArgs = getCommunicationInterfaceArguments( this, connectivity )
            communicationInterfaceArgs = [  ];
            if isempty( connectivity )





                processCommunicationInterfaceArguments = false;
            else







                processCommunicationInterfaceArguments = true;
            end

            if processCommunicationInterfaceArguments




                communicationInterface =  ...
                    Simulink.ExtMode.TargetFrameworkUtils.getBoardCommunicationInterfaceForXCPTransport( this.Board,  ...
                    connectivity.XCP.XCPTransport );
                if ~isempty( communicationInterface.APIImplementations )
                    if ~isempty( communicationInterface.APIImplementations.MainFunction )
                        communicationInterfaceArgs =  ...
                            communicationInterface.APIImplementations.MainFunction.Arguments;
                    end
                end
            end
        end

        function createAppExecutionService( this )
            connectivity = Simulink.ExtMode.TargetFrameworkUtils.getActiveExternalModeConnectivity( this.Model,  ...
                this.Board );

            if isempty( connectivity )

                connectionParams = [  ];
            else

                connectionParams = coder.internal.xcp.parseExtModeArgs(  ...
                    get_param( this.Model, 'ExtModeMexArgs' ),  ...
                    connectivity.getTransport,  ...
                    this.Model,  ...
                    this.RootFolder );
            end


            options = targetframework.services.appexecution.ExecutionOptions(  );

            variableExpansion = this.createVariableExpansion( this.Board,  ...
                this.Exe,  ...
                connectionParams );
            options.VariableExpansion = variableExpansion;
            this.VariableExpansion = variableExpansion;

            options.Deploy = true;
            options.Execute = true;

            communicationInterfaceArgs = this.getCommunicationInterfaceArguments( connectivity );
            if ~isempty( communicationInterfaceArgs )

                options.ApplicationArguments = communicationInterfaceArgs;
                this.CommunicationInterfaceArgs = communicationInterfaceArgs;
            end



            import targetframework.internal.model.foundation.ServiceMethodRequirement;



            options.ServiceInterfaceRequirements.setMethodRequirement( 'startApplication', ServiceMethodRequirement.Required );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'stopApplication', ServiceMethodRequirement.Required );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'getApplicationStatus', ServiceMethodRequirement.Required );



            options.ServiceInterfaceRequirements.setMethodRequirement( 'open', ServiceMethodRequirement.Optional );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'loadApplication', ServiceMethodRequirement.Optional );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'unloadApplication', ServiceMethodRequirement.Optional );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'close', ServiceMethodRequirement.Optional );


            options.ServiceInterfaceRequirements.setMethodRequirement( 'terminateApplication', ServiceMethodRequirement.Optional );


            options.ServiceInterfaceRequirements.setMethodRequirement( 'getStandardOutput', ServiceMethodRequirement.Optional );
            options.ServiceInterfaceRequirements.setMethodRequirement( 'getStandardError', ServiceMethodRequirement.Optional );


            this.AppExecutionService = targetframework.services.appexecution.createExecutionManager( this.Exe,  ...
                this.Board,  ...
                options );
        end
    end
end



