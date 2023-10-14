classdef CustomPPFunctionWrapper < matlab.internal.preprocessingApp.tasks.UserAuthoredTask
    properties ( Dependent )
        FunctionName
    end
    methods
        function v = get.FunctionName( obj )
            v = obj.FunctionNameI;
        end
        function set.FunctionName( obj, v )
            obj.FunctionNameI = v;
            obj.updateCode;
        end
    end

    properties ( Access = protected, Hidden = true )
        FunctionNameI
        Arguments
    end

    methods
        function obj = CustomPPFunctionWrapper( figure, workspace, NVPairs )
            arguments
                figure = uifigure
                workspace = "base"
                NVPairs.FunctionName( 1, 1 )string
                NVPairs.Name( 1, 1 )string = ""
                NVPairs.Description( 1, 1 )string = ""
                NVPairs.Code string = string.empty
                NVPairs.PlotCode string = string.empty
                NVPairs.State( 1, 1 )struct = struct
                NVPairs.Summary( 1, 1 )string = ""
                NVPairs.VariableName( 1, 1 )string = ""
                NVPairs.TableVariableName( 1, 1 )string = ""
                NVPairs.HasTableVariable( 1, 1 )logical = false
                NVPairs.DocFunctions string = string.empty
            end

            obj@matlab.internal.preprocessingApp.tasks.UserAuthoredTask(  ...
                figure ...
                , workspace ...
                , 'Name', NVPairs.Name ...
                , 'Description', NVPairs.Description ...
                , 'Code', NVPairs.FunctionName ...
                , 'PlotCode', NVPairs.PlotCode ...
                , 'State', NVPairs.State ...
                , 'Summary', NVPairs.Summary ...
                , 'VariableName', NVPairs.VariableName ...
                , 'TableVariableName', NVPairs.TableVariableName ...
                , 'HasTableVariable', NVPairs.HasTableVariable ...
                , 'DocFunctions', NVPairs.DocFunctions ...
                );

            if isempty( obj.Name ) || strlength( obj.Name ) == 0
                obj.Name = NVPairs.FunctionName;
            end
            obj.FunctionNameI = NVPairs.FunctionName;
            obj.updateCode;
        end
    end

    methods ( Access = { ?matlab.internal.preprocessingApp.tasks.UserAuthoredTask, ?matlab.unittest.TestCase } )
        function path = getPath( obj )
            path = mfilename( 'class' );
            path = path + "('FunctionName', '" + obj.FunctionName + "', 'HasTableVariable', " + obj.HasTableVariable + ")";
        end

        function updateCode( obj )
            clf( obj.UIFigure );

            varName = obj.VARNAME_TAG;
            if obj.HasTableVariable
                varName = obj.TABLEVARIABLE_TAG;
            end
            [ args, h1 ] = matlab.internal.preprocessingApp.tasks.getCustomPPFunctionParameters( obj.FunctionName );
            if isempty( h1 ) || strlength( h1 ) == 0
                h1 = obj.FunctionName;
            end
            h1 = sprintf( "%% %s\n", replace( h1, newline, newline + "%" ) );
            cmd = sprintf( "%s\n{$%s} = %s({$%s}", h1, varName, obj.FunctionName, varName );

            obj.Arguments = containers.Map(  );
            if ~isempty( args )
                for i = 2:length( args )
                    if ~isempty( args( i ).name ) && strlength( strtrim( args( i ).name ) ) > 0
                        argName = split( args( i ).name, "." );
                        if length( argName ) > 1
                            argName = argName( 2 );
                            argCmd = "'" + argName + "', {$" + argName + "}";
                        else
                            argCmd = "{$" + argName + "}";
                        end
                        cmd = cmd + ", " + argCmd;

                        obj.Arguments( argName ) = args( i );
                    end
                end
            end

            cmd = cmd + ")";

            obj.Code = cmd;
            obj.Summary_private = h1;
            obj.createUI;
        end

        function comp = createComponentForArgument( obj, argName, layout, row )
            comp = [  ];
            if ~isempty( obj.Arguments ) && isKey( obj.Arguments, argName )
                args = obj.Arguments( argName );
                if ~isempty( args.type ) ...
                        && strcmp( replace( args.dims, " ", "" ), "(1,1)" ) ...
                        && ( ismember( args.type, [ "double", "single", "half", "int8", "int16", "int32", "int64", "uint8", "uint16", "uint32", "uint64" ] ) ...
                        || contains( args.validators, 'mustBeNumeric' ) )

                    defaultValue = 0;
                    if ~isempty( args.defaultValue ) && strlength( args.defaultValue ) > 0
                        defaultValue = str2double( args.defaultValue );
                    end
                    lowerLimit =  - Inf;
                    upperLimit = Inf;
                    lowerBoundInclusive = true;
                    upperBoundInclusive = true;

                    if contains( args.validators, 'mustBePositive' )
                        lowerLimit = 0;
                        lowerBoundInclusive = false;
                    end

                    if contains( args.validators, 'mustBeNonpositive' )
                        upperLimit = 0;
                        upperBoundInclusive = true;
                    end

                    if contains( args.validators, 'mustBeNegative' )
                        upperLimit = 0;
                        upperBoundInclusive = false;
                    end

                    if contains( args.validators, 'mustBeNonnegative' )
                        lowerLimit = 0;
                        lowerBoundInclusive = true;
                    end

                    if contains( args.validators, 'mustBeGreaterThanOrEqual' )
                        try
                            s = regexp( args.validators, "mustBeGreaterThanOrEqual\s*\(.*?,\s*(?<value>[0-9e\-\.Inf]+)\)", "names" );
                            lowerLimit = str2double( s.value );
                            lowerBoundInclusive = true;
                        catch
                        end
                    end

                    if contains( args.validators, 'mustBeGreaterThan' )
                        try
                            s = regexp( args.validators, "mustBeGreaterThan\s*\(.*?,\s*(?<value>[0-9e\-\.Inf]+)\)", "names" );
                            lowerLimit = str2double( s.value );
                            lowerBoundInclusive = false;
                        catch
                        end
                    end

                    if contains( args.validators, 'mustBeLessThanOrEqual' )
                        try
                            s = regexp( args.validators, "mustBeLessThanOrEqual\s*\(.*?,\s*(?<value>[0-9e\-\.Inf]+)\)", "names" );
                            upperLimit = str2double( s.value );
                            upperBoundInclusive = true;
                        catch
                        end
                    end

                    if contains( args.validators, 'mustBeLessThan' )
                        try
                            s = regexp( args.validators, "mustBeLessThan\s*\(.*?,\s*(?<value>[0-9e\-\.Inf]+)\)", "names" );
                            upperLimit = str2double( s.value );
                            upperBoundInclusive = false;
                        catch
                        end
                    end

                    if contains( args.validators, 'mustBeMember' )
                        try
                            s = regexp( args.validators, "mustBeMember\s*\(.*?,\s*(?<value>.+?)\)", "names" );
                            items = s.value;
                            try
                                items = eval( s.value );
                            catch
                            end
                            lowerLimit = min( items );
                            upperLimit = max( items );
                            lowerBoundInclusive = true;
                            upperBoundInclusive = true;
                        catch
                        end
                    end

                    if contains( args.validators, 'mustBeInRange' )
                        try
                            s = regexp( args.validators, "mustBeInRange\s*\(.*?,\s*(?<lowerLimit>[0-9e\-\.Inf]+)\s*,\s*(?<upperLimit>[0-9e\-\.Inf]+)\s*(?<flags>,.*?){0,1}\)", "names" );
                            lowerLimit = str2double( s.lowerLimit );
                            upperLimit = str2double( s.upperLimit );
                            lowerBoundInclusive = true;
                            upperBoundInclusive = true;
                            if contains( s.flags, "exclusive" ) || contains( s.flags, "exclude-lower" )
                                lowerBoundInclusive = false;
                            end
                            if contains( s.flags, "exclusive" ) || contains( s.flags, "exclude-upper" )
                                upperBoundInclusive = false;
                            end
                        catch
                        end
                    end

                    roundValues = contains( args.validators, 'mustBeInteger' );

                    comp = uispinner( layout, 'Value', defaultValue, 'Limits', [ lowerLimit, upperLimit ], 'LowerLimitInclusive', lowerBoundInclusive, 'UpperLimitInclusive', upperBoundInclusive, 'RoundFractionalValues', roundValues );
                elseif strcmp( args.type, "logical" ) && strcmp( replace( args.dims, " ", "" ), "(1,1)" )
                    defaultValue = false;
                    if ~isempty( args.defaultValue )
                        try
                            defaultValue = eval( args.defaultValue );
                        catch
                        end
                    end
                    comp = uicheckbox( layout, 'Value', defaultValue, 'Text', "" );
                else
                    defaultValue = "";
                    if ~isempty( args.defaultValue ) && strlength( args.defaultValue ) > 0
                        defaultValue = args.defaultValue;
                    end

                    if contains( args.validators, 'mustBeMember' )
                        try
                            s = regexp( args.validators, "mustBeMember\s*\(.*?,\s*(?<value>.+?)\)", "names" );
                            items = s.value;
                            try
                                items = eval( items );
                            catch
                            end
                            itemsData = """" + items + """";
                            comp = uidropdown( layout, 'Value', defaultValue, 'Items', items, 'ItemsData', itemsData );
                        catch
                        end
                    else
                        comp = uieditfield( layout, 'Value', defaultValue );
                    end

                end

                comp.Tooltip = args.comment;
            end

            if isempty( comp )
                comp = uieditfield( layout );
            end
            comp.Layout.Row = row;
            comp.Layout.Column = 2;
            comp.Tag = argName;
        end
    end
end

