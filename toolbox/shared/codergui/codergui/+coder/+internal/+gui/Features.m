classdef ( Hidden, Sealed )Features < handle
    enumeration
        FixedPointTraceability( 'F2FTrace' )
        MlfbTraceability( 'MlfbTrace' )
        Half( 'HalfSupport' )
    end

    properties ( GetAccess = private, SetAccess = immutable )
        Key
    end

    properties ( Dependent )
        Enabled
    end

    methods
        function this = Features( key )
            this.Key = key;
        end

        function enabled = get.Enabled( this )
            enabled = coderapp.internal.globalconfig( this.Key );
        end

        function set.Enabled( this, enabled )
            this.setEnabled( enabled );
        end

        function varargout = setEnabled( this, enabled, ~ )
            arguments
                this
                enabled( 1, 1 ){ mustBeNumericOrLogical( enabled ) }
                ~
            end

            if nargout ~= 0
                varargout = { this.Enabled };
            end

            coderapp.internal.globalconfig( this.Key, enabled );

            if nargout == 0
                if enabled
                    enabledStr = 'enabled';
                else
                    enabledStr = 'disabled';
                end
                fprintf( 'Feature "%s" %s for the current session.\n', char( this ), enabledStr );
            end
        end

        function enabled = isEnabled( this )
            enabled = this.Enabled;
        end

        function cleanup = setEnabledWithCleanup( this, enabled )
            if this.Enabled ~= enabled
                origEnabled = this.Enabled;
                this.setEnabled( enabled );
                cleanup = onCleanup( @(  )this.setEnabled( origEnabled ) );
            else
                cleanup = [  ];
            end
        end
    end
end

