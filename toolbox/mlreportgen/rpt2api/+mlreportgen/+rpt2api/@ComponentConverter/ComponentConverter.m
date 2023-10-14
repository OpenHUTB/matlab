classdef ( Abstract )ComponentConverter < handle

    properties

        VariableName string

        Component

        FID

        RptFileConverter

        AssignTo

    end

    properties ( Access = protected )
        VariableNameCounter = [  ];
    end

    properties ( Constant )
        RptStateVariable = "rptState";
    end


    methods

        function convert( obj )








            import mlreportgen.rpt2api.ComponentConverter

            if isprop( obj.Component, "Active" ) && ~obj.Component.Active


                template = ComponentConverter.getTemplate( 'inactive' );
                fprintf( obj.FID, template, class( obj.Component ) );
            else
                write( obj );
                convertComponentChildren( obj );
            end
        end

        function fid = get.FID( obj )
            fid = obj.RptFileConverter.FID;
        end

    end

    methods ( Access = protected )

        function init( obj, component, rptFileConverter )
            obj.Component = component;
            obj.RptFileConverter = rptFileConverter;
            obj.AssignTo = [  ];
        end

        function write( ~ )



        end

        function child = getFirstChildComponent( obj )



            child = down( obj.Component );
        end

        function convertComponentChildren( obj )



            import mlreportgen.rpt2api.*

            objName = getVariableName( obj );
            if ~isempty( objName )
                push( obj.RptFileConverter.VariableNameStack, objName );
            end

            children = getComponentChildren( obj );
            n = numel( children );
            for i = 1:n
                cmpn = children{ i };
                c = getConverter( obj.RptFileConverter.ConverterFactory,  ...
                    cmpn, obj.RptFileConverter );
                convert( c );
            end
            pop( obj.RptFileConverter.VariableNameStack );
        end

        function children = getComponentChildren( obj )




            children = {  };
            child = getFirstChildComponent( obj );
            while ~isempty( child )
                children = [ children, { child } ];%#ok<AGROW>
                child = right( child );
            end
        end

        function str = makeAddString( ~, toVarName, fromVarName )
            if contains( toVarName, "Rptr" )
                methodName = "add";
            else
                methodName = "append";
            end
            str = sprintf( "%s(%s, %s);\n\n", methodName, toVarName,  ...
                fromVarName );
        end

        function writeMultilineString( obj, string )







            lines = split( string, newline );
            n = numel( lines );
            for i = 1:n - 1
                line = lines{ i };
                line = strrep( line, '"', '""' );
                fprintf( obj.FID, '"%s" + newline + ...\n', line );
            end

            line = lines{ n };
            line = strrep( line, '"', '""' );
            fprintf( obj.FID, '"%s";', line );
        end

        function index = getSiblingIndex( obj )





            index = 1;
            cmpnClass = class( obj.Component );
            prevSibling = left( obj.Component );
            while ~isempty( prevSibling )
                if string( class( prevSibling ) ) == cmpnClass
                    index = index + 1;
                end
                prevSibling = left( prevSibling );
            end
        end

        function index = getLoopIndex( obj )
            index = 0;
            parent = up( obj.Component );
            while ~isempty( parent )
                if isLoopComponent( obj, parent )
                    index = index + 1;
                end
                parent = up( parent );
            end
        end

        function name = makeVariableName( obj )










            name = sprintf( "%s%d", getVariableRootName( obj ),  ...
                getSiblingIndex( obj ) );






            variableNameCounter = getVariableNameCounter( obj );
            if ~isempty( variableNameCounter )
                name = strcat( name, "_", num2str( variableNameCounter ) );
            end









        end

        function tf = isLoopComponent( ~, cmpn )
            persistent loopCmpnClasses

            if isempty( loopCmpnClasses )
                loopCmpnClasses = [  ...
                    "rptgen_lo.clo_for"
                    ];%#ok<NBRAK>
            end
            tf = ~isempty( find( contains( loopCmpnClasses, class( cmpn ) ), 1 ) );
        end

        function counter = getVariableNameCounter( obj )









            counter = obj.VariableNameCounter;
        end

        function name = getVariableRootName( ~ )







            name = "";
        end

        function name = getVariableName( obj )





            if isempty( obj.VariableName )
                obj.VariableName = makeVariableName( obj );
            end
            name = obj.VariableName;
        end

        function writeStartBanner( obj )


            name = obj.Component.getName(  );
            if isempty( name )
                name = class( obj.Component );
            end
            fprintf( obj.FID, "%s\n", "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" );
            fprintf( obj.FID, "%% Start %s\n\n", string( name ) );
        end

        function writeEndBanner( obj )


            name = obj.Component.getName(  );
            if isempty( name )
                name = class( obj.Component );
            end

            fprintf( obj.FID, "%% End %s\n", string( name ) );
            fprintf( obj.FID, "%s\n\n", "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%" );
        end

        function ctx = getContext( obj, allowedCtx )


            ctx = "";
            parent = up( obj.Component );
            while ~isempty( parent )
                parentClass = class( parent );
                if contains( parentClass, allowedCtx )
                    ctx = parentClass;
                    break ;
                end
                parent = up( parent );
            end
        end

    end

    methods ( Static )

        function folder = getClassFolder(  )
            folder = fileparts( mfilename( 'fullpath' ) );
        end

        function template = getTemplate( templateName )
            import mlreportgen.rpt2api.ComponentConverter
            templateFolder = fullfile( ComponentConverter.getClassFolder,  ...
                'templates' );
            templatePath = fullfile( templateFolder, [ templateName, '.txt' ] );
            template = fileread( templatePath );
        end

        function out = classesToClearAfterConversion( className )

            arguments
                className string = string.empty(  );
            end

            persistent ClassesToClear;
            if nargin
                ClassesToClear = [ ClassesToClear, className ];
            end

            out = ClassesToClear;
        end

    end

end

