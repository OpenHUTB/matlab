classdef ( Abstract )HierarchyLoggable < coderapp.internal.log.Loggable

    properties ( SetAccess = immutable, GetAccess = private )
        OwnLogger
    end

    methods
        function this = HierarchyLoggable( loggerId, opts )
            arguments
                loggerId( 1, 1 )string{ mustBeValidVariableName( loggerId ) } = "placeholder"
                opts.Parent{ mustBeScalarOrEmpty( opts.Parent ) } = [  ]
                opts.EnableLogging logical{ mustBeScalarOrEmpty( opts.EnableLogging ) }
            end

            if nargin > 0
                parent = opts.Parent;
                parentLogger = [  ];
                if ~isempty( parent )
                    if isa( parent, 'coderapp.internal.log.Loggable' )
                        if ~isempty( parent.Logger )
                            parentLogger = parent.Logger;
                        end
                    elseif isa( parent, 'coderapp.internal.log.Logger' )
                        parentLogger = parent;
                    else
                        error( 'Parent argument must be a Loggable or Logger instance: %s', class( parent ) );
                    end
                    if isempty( parentLogger )
                        return
                    end
                end
                if ~isempty( parentLogger )
                    this.Logger = parent.Logger.create( loggerId );
                else
                    if isfield( opts, 'EnableLogging' ) && ~isempty( opts.EnableLogging )
                        args = { 'Enable', opts.EnableLogging };
                    else
                        args = {  };
                    end
                    this.Logger = coderapp.internal.log.new( args{ : }, BaseId = loggerId );
                end
                this.OwnLogger = this.Logger;
            end
        end
    end
end


