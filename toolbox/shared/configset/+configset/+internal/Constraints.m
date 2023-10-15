classdef Constraints < handle







    properties
        Constraint( 1, : )configset.internal.Constraint
        DialogTooltip
    end

    methods
        function obj = Constraints( file )




            if nargin > 0
                obj.load( file );
            end
        end

        function load( obj, file )




            s = readstruct( file, 'FileType', 'xml', 'StructSelector',  ...
                '/configset/constraints' );


            obj.Constraint = configset.internal.Constraint.empty;


            arrayfun( @( x )obj.add( x.name, x.value, x.status ),  ...
                s.param, 'ErrorHandler', @obj.errorHandler );
        end

        function add( obj, name, value, status )

            if isstruct( value )


                value = str2func( value.functionAttribute );
            end
            if ismissing( status )
                status = "";
            end
            obj.Constraint( end  + 1 ) = configset.internal.Constraint(  ...
                name, value, status );
        end

        function apply( obj, cs, param, value )


            arguments
                obj
                cs
            end
            arguments( Repeating )
                param( 1, 1 )string
                value
            end

            for constraint = obj.Constraint
                if ~cs.isValidParam( constraint.Name )

                    warning( message( 'configset:diagnostics:PropNotExist', constraint.Name ) );
                    continue
                end
                args = reshape( [ param';value' ], 1, length( value ) * 2 );
                apply( constraint, cs, args{ : } );
            end

            obj.applyDialogCustomization( cs );
        end

        function applyStatus( obj, cs )

            arrayfun( @( x )x.applyStatus( cs ), obj.Constraint );
            obj.applyDialogCustomization( cs );
        end

        function out = getIncompatibleParameters( obj, cs )


            out = [ obj.Constraint( ~arrayfun( @( x )x.isCompatible( cs ),  ...
                obj.Constraint ) ).Name ];
        end

        function fix( obj, cs )




            configset.internal.Constraints.reset( cs );
            for constraint = obj.Constraint
                if ~cs.isValidParam( constraint.Name )
                    continue
                end
                if constraint.isCompatible( cs )
                    applyStatus( constraint, cs );
                else
                    apply( constraint, cs );
                end
            end
            obj.applyDialogCustomization( cs );
        end

        function out = getDialogCustomization( obj, cs )

            out = '';


            p = obj.getHiddenParameters;
            if ~isempty( p )
                out = [ out, sprintf( '<custom id="%s" visible="off"/>', p ) ];
            end


            p = obj.getDisabledParameters;




            p = p( arrayfun( @( x )~cs.getPropEnabled( x ), p ) );

            if ~isempty( p ) && ~isempty( obj.DialogTooltip )
                info = sprintf( 'info="%s"', obj.DialogTooltip );
                out = [ out, sprintf( [ '<custom id="%s" enabled="off" ', info, '/>' ], p ) ];
            end

            if ~isempty( out )
                out = [ '<configset_customization>', out, '</configset_customization>' ];
            end
        end

        function out = getDisabledParameters( obj )

            parameters = obj.getAllParameters;
            out = parameters( arrayfun( @( x )x.Status ~= "", obj.Constraint ) );
        end

        function out = getHiddenParameters( obj )

            parameters = obj.getAllParameters;
            out = parameters( arrayfun( @( x )x.Status == "Hidden", obj.Constraint ) );
        end
    end

    methods ( Static )
        function reset( cs )



            if get_param( cs, 'IsERTTarget' ) == "on"

                cs.reenableAllProps;







                dialogCache = cs.getConfigSetCache;
                if ~isempty( dialogCache )
                    dialogCache.reenableAllProps;
                end
            end


            if ~isempty( cs.getDialogHandle )
                view = configset.internal.util.getHTMLView( cs );
                view.cfg = [  ];
                cs.refreshDialog;
            end
        end
    end

    methods ( Access = private )
        function errorHandler( ~, s, varargin )

            warning( s.identifier, s.message );
        end

        function out = getAllParameters( obj )

            out = arrayfun( @( x )x.Name, obj.Constraint );
        end

        function applyDialogCustomization( obj, cs )

            if ~isempty( cs.getDialogHandle )
                view = configset.internal.util.getHTMLView( cs );
                view.cfg = struct( 'custom', obj.getDialogCustomization( cs ) );
                cs.refreshDialog;
            end
        end
    end
end


