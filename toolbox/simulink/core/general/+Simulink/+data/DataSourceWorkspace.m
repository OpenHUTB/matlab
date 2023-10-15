classdef DataSourceWorkspace < handle

    properties ( Access = private, Hidden = true )
        m_workspace
    end


    methods ( Access = private, Hidden )

        function obj = DataSourceWorkspace( workspace )
            obj.m_workspace = workspace;
        end

        function val = getOneVarValue( obj, onevar, errorOutForMissing )
            if obj.hasVariables( onevar )
                val = getValue( obj.m_workspace, onevar );
            else
                if errorOutForMissing
                    throwAsCaller( MException( message( 'MATLAB:undefinedVariable', onevar ) ) );
                else
                    val = missing;
                end
            end
        end

    end


    methods ( Access = public, Hidden, Static )

        function obj = createWithInternalWorkspace( workspace )
            arguments
                workspace( 1, 1 )matlab.internal.lang.Workspace
            end
            obj = Simulink.data.DataSourceWorkspace( workspace );
        end

    end


    methods ( Access = public )



        function list = listVariables( obj )
            list = listVariables( obj.m_workspace );
        end

        function exists = hasVariables( obj, var )
            arguments
                obj
                var{ mustBeText, mustBeValidVarName }
            end
            var = convertCharsToStrings( var );
            exists = arrayfun( @( v )hasVariables( obj.m_workspace, v ), var );
        end

        function val = getVariable( obj, var, errorOutForMissing )
            arguments
                obj
                var{ mustBeTextScalar, mustBeValidVarName }
                errorOutForMissing( 1, 1 )logical = true;
            end
            var = convertCharsToStrings( var );
            val = obj.getOneVarValue( var, errorOutForMissing );
        end

        function val = getVariables( obj, var, errorOutForMissing )
            arguments
                obj
                var{ mustBeText, mustBeValidVarName }
                errorOutForMissing( 1, 1 )logical = true;
            end
            if ( ischar( var ) || isstring( var ) ) && isscalar( var )
                val = obj.getOneVarValue( var, errorOutForMissing );
            else
                var = convertCharsToStrings( var );
                val = arrayfun( @( v )obj.getOneVarValue( v, errorOutForMissing ),  ...
                    var, 'UniformOutput', false );
            end
        end

        function setVariable( obj, var, val )
            arguments
                obj
                var{ mustBeTextScalar, mustBeValidVarName }
                val
            end
            strvar = convertCharsToStrings( var );
            assignVariable( obj.m_workspace, strvar, val )
        end

        function setVariables( obj, var, val )
            arguments
                obj
                var{ mustBeText, mustBeValidVarName }
                val{ mustBeCell, varValMustBeCompatible( var, val ) }
            end
            strvar = convertCharsToStrings( var );
            if isscalar( strvar )
                assignVariable( obj.m_workspace, strvar, val{ 1 } );
            else
                cellvars = convertStringsToChars( var );
                cellfun( @( vr, vl )assignVariable( obj.m_workspace, vr, vl ),  ...
                    cellvars, val );
            end
        end

        function clearVariables( obj, var )
            arguments
                obj
                var{ mustBeText, mustBeValidVarName }
            end
            var = convertCharsToStrings( var );
            arrayfun( @( v )clearVariables( obj.m_workspace, v ), var );
        end



        function clearAllVariables( obj )
            clearVariables( obj.m_workspace );
        end

        function run( obj, mscriptfile )
            arguments
                obj
                mscriptfile{ mustBeTextScalar, mustBeFile };
            end
            [ ~, scriptName, ext ] = fileparts( mscriptfile );
            isScript = false;

            if strcmp( ext, '.m' ) || strcmp( ext, '.mlx' )
                try
                    nargin( mscriptfile );
                catch me
                    if strcmp( me.identifier, 'MATLAB:nargin:isScript' )


                        evaluateIn( obj.m_workspace, scriptName );
                        isScript = true;
                    end
                end
            end
            if ~isScript
                throwAsCaller( MException( message( 'Simulink:Data:DSWSPInvalidFileType', mscriptfile ) ) );
            end
        end

    end


    methods ( Access = public, Hidden )

        function tbl = getVariableTable( obj )
            varNames = obj.listVariables(  );
            mStruct = struct( [  ] );
            for i = 1:length( varNames )
                mStruct( i, 1 ).Name = varNames( i );
                mStruct( i, 1 ).Value = obj.getVariable( varNames( i ) );
            end
            tbl = struct2table( mStruct );
        end
    end
end


function varValMustBeCompatible( var, val )
if ischar( var )
    var = convertCharsToStrings( var );
end
if ~isequal( size( var ), size( val ) )
    throwAsCaller( MException( message( 'Simulink:Data:DSWSPIncompatibleNameValueArguments' ) ) );
end
end

function mustBeValidVarName( varNames )
varNames = convertCharsToStrings( varNames );

invalidVarNamesMsg = [  ];
for i = 1:numel( varNames )
    if ~isvarname( varNames( i ) )
        varNameChar = [ '''', convertStringsToChars( varNames( i ) ), '''' ];
        if isempty( invalidVarNamesMsg )
            invalidVarNamesMsg = varNameChar;
        else
            invalidVarNamesMsg = [ invalidVarNamesMsg, ', ', varNameChar ];%#ok
        end
    end
end
if ischar( invalidVarNamesMsg )
    throwAsCaller( MException( message( 'Simulink:Data:DSWSPInvalidVarNames', invalidVarNamesMsg ) ) );
end
end

function mustBeCell( var )
if ~iscell( var )
    throwAsCaller( MException( message( 'Simulink:Data:DSWSPVarMustBeCell' ) ) );
end
end



