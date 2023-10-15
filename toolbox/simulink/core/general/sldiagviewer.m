classdef sldiagviewer < handle

    methods ( Static = true, Access = 'public' )
        function diary( varargin )
            persistent diary_map;
            if ( isempty( diary_map ) )
                diary_map = containers.Map;
            end

            if ( nargin > 2 )
                error( message( 'Simulink:SLMsgViewer:DiaryInvalidNumberArgs' ).getString(  ) );
            end

            persistent default_filename;
            persistent last_file;

            if isempty( last_file )
                last_file = sldiagviewer.getAbsoluteFilePath( 'diary.txt' );
            end


            if isempty( default_filename )
                filename = sldiagviewer.getAbsoluteFilePath( 'diary.txt' );
            else
                filename = default_filename;
            end
            encoding = 'default';

            if ( nargin == 1 )


                if ( strcmpi( varargin{ 1 }, 'on' ) )
                    if ( ~diary_map.isKey( last_file ) )
                        try
                            Simulink.output.startLogging( last_file );
                        catch err
                            throwAsCaller( err )
                        end
                    end

                    if strfind( last_file, 'diary' )
                        default_filename = last_file;
                    end
                    diary_map( last_file ) = true;
                    return ;
                elseif ( strcmpi( varargin{ 1 }, 'off' ) )
                    if ( diary_map.isKey( last_file ) )
                        try
                            Simulink.output.stopLogging( last_file );
                        catch err
                            throwAsCaller( err )
                        end
                        remove( diary_map, last_file );
                    end

                    if strfind( last_file, 'diary' )
                        default_filename = '';
                    end
                    return ;
                end
                filename = sldiagviewer.getAbsoluteFilePath( varargin{ 1 } );

            elseif ( nargin == 2 )
                filename = sldiagviewer.getAbsoluteFilePath( varargin{ 1 } );
                encoding = varargin{ 2 };
                if ( strcmp( encoding, 'UTF-8' ) == 0 )
                    error( message( 'Simulink:SLMsgViewer:DiaryInvalidEncoding' ).getString(  ) );
                end
            end


            if ( diary_map.isKey( filename ) )
                enable = false;
            else
                enable = true;
            end


            if ( enable )
                if ( strcmp( encoding, 'default' ) == 1 )
                    try
                        Simulink.output.startLogging( filename );
                    catch err
                        throwAsCaller( err );
                    end
                else
                    try
                        Simulink.output.startLogging( filename, 'Encoding', encoding );
                    catch err
                        throwAsCaller( err );
                    end
                end
                diary_map( filename ) = true;

                if strfind( filename, 'diary' )
                    default_filename = filename;
                end
            else
                try
                    Simulink.output.stopLogging( filename );
                catch err
                    throwAsCaller( err )
                end
                diary_map.remove( filename );

                if strfind( filename, 'diary' )
                    default_filename = '';
                end
            end
            last_file = filename;
        end

        function stageObj = createStage( varargin )
            try
                if nargin == 0
                    throwAsCaller( MException( message( 'MATLAB:class:UndefinedFunction', 'createStage' ) ) );
                end
                stageObj = Simulink.output.Stage( varargin{ : }, 'UIMode', true );
            catch err
                if strcmp( err.identifier, 'MATLAB:dispatcher:noMatchingConstructor' )
                    throwAsCaller( MException( message( 'MATLAB:class:UndefinedFunction', 'createStage' ) ) );
                else
                    throwAsCaller( err );
                end
            end
        end

        function status = reportWarning( varargin )
            try
                status = Simulink.output.warning( varargin{ : } );
            catch err
                if strcmp( err.identifier, 'MATLAB:UndefinedFunction' )
                    throwAsCaller( MException( message( 'MATLAB:class:UndefinedFunction', 'reportWarning' ) ) );
                else
                    throwAsCaller( err );
                end
            end
        end

        function status = reportError( varargin )
            try
                status = Simulink.output.error( varargin{ : } );
            catch err
                if strcmp( err.identifier, 'MATLAB:UndefinedFunction' )
                    throwAsCaller( MException( message( 'MATLAB:class:UndefinedFunction', 'reportError' ) ) );
                else
                    throwAsCaller( err );
                end
            end
        end

        function status = reportInfo( varargin )
            try
                status = Simulink.output.info( varargin{ : } );
            catch err
                if strcmp( err.identifier, 'MATLAB:UndefinedFunction' )
                    throwAsCaller( MException( message( 'MATLAB:class:UndefinedFunction', 'reportInfo' ) ) );
                else
                    throwAsCaller( err );
                end
            end
        end

        function reportSimulationMetadataDiagnostics( simulationOutput )
            arguments
                simulationOutput( 1, 1 )Simulink.SimulationOutput
            end

            try
                modelName = simulationOutput.SimulationMetadata.ModelInfo.ModelName;
                stageName = message( 'Simulink:SLMsgViewer:Simulation_Stage_Name' ).getString(  );

                sldiagviewer.createStage( stageName, 'ModelName', modelName );
                errors = simulationOutput.SimulationMetadata.ExecutionInfo.ErrorDiagnostic;
                warnings = simulationOutput.SimulationMetadata.ExecutionInfo.WarningDiagnostics;


                for e = 1:length( errors )
                    errors( e ).Diagnostic.reportAsError;
                end

                for w = 1:length( warnings )
                    warnings( w ).Diagnostic.reportAsWarning;
                end

                slmsgviewer.show( modelName );
            catch err
                throwAsCaller( err );
            end
        end

    end


    methods ( Static = true, Access = 'private' )
        function [ absFilePath ] = getAbsoluteFilePath( aRelativeFilePath )
            [ dirname, filename, ext ] = fileparts( aRelativeFilePath );
            absFilePath = fullfile( pwd, dirname, strcat( filename, ext ) );
            if ( exist( fileparts( absFilePath ) ) == 0 )
                absFilePath = aRelativeFilePath;
            end
        end
    end

end

