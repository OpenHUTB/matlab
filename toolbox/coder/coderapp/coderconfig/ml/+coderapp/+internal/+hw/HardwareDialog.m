classdef ( Sealed )HardwareDialog < coderapp.internal.log.Loggable

    properties ( SetAccess = immutable )
        HardwareName
        Hardware
    end

    properties ( Dependent )
        Showing
    end

    properties ( Dependent, SetAccess = immutable )
        Data
    end

    properties ( SetAccess = private, GetAccess = { ?coderapp.internal.hw.HardwareDialog, ?coderapp.internal.hw.HardwareDialogHelper }, Transient )
        Dialog
    end

    properties ( Access = private, Transient )
        Helper
        NextData = struct.empty
        OnClose
    end

    methods
        function this = HardwareDialog( hwArg, opts )
            arguments
                hwArg{ mustBeA( hwArg, [ "char", "string", "coder.Hardware" ] ) } = ''
                opts.InitialData struct{ mustBeScalarOrEmpty( opts.InitialData ) } = struct.empty
                opts.OnClose function_handle{ mustBeScalarOrEmpty( opts.OnClose ) } = function_handle.empty
                opts.Show( 1, 1 ){ mustBeNumericOrLogical( opts.Show ) } = true
                opts.Logger( 1, 1 )coderapp.internal.log.Logger
            end

            this.OnClose = opts.OnClose;
            this.NextData = opts.InitialData;

            if isfield( opts, 'Logger' )
                this.Logger = opts.Logger;
            end
            if ~isempty( hwArg )
                if ischar( hwArg ) || isstring( hwArg )
                    this.HardwareName = hwArg;
                else
                    this.HardwareName = hwArg.Name;
                    this.Hardware = hwArg;
                end
                this.Logger.trace( 'HardwareDialog created for "%s"', this.HardwareName );
            end
            if opts.Show
                this.show(  );
            end
        end

        function delete( this )
            this.close(  );
        end

        function showing = get.Showing( this )
            showing = ~isempty( this.Dialog ) && isa( this.Dialog, 'DAStudio.Dialog' );
        end

        function set.Showing( this, showing )
            if showing
                this.show(  );
            else
                this.close(  );
            end
        end

        function data = get.Data( this )
            if ~isempty( this.Helper )
                data = this.Helper.HardwareData;
            else
                data = this.NextData;
            end
        end

        function show( this )
            logCleanup = this.Logger.trace( 'Entering show' );%#ok<NASGU>
            if this.Showing
                this.Dialog.show(  );
                return
            elseif ~isempty( this.Hardware )
                arg = this.Hardware;
            elseif ~isempty( this.HardwareName )
                arg = this.HardwareName;
            else
                return
            end
            this.Helper = coderapp.internal.hw.HardwareDialogHelper( this, arg, this.OnClose, this.NextData );
            this.Dialog = DAStudio.Dialog( this.Helper );
        end

        function close( this, apply )
            arguments
                this
                apply( 1, 1 )logical = true
            end

            logCleanup = this.Logger.trace( 'Entering close (apply=%g)', apply );%#ok<NASGU>
            if isempty( this.Dialog )
                return
            elseif isa( this.Dialog, 'DAStudio.Dialog' )
                this.Logger.debug( 'Closing open dialog' );
                if apply
                    this.Dialog.apply(  );
                end
                this.Dialog.delete(  );
            end
            this.Dialog = [  ];
            this.Helper = [  ];
        end
    end
end

