classdef FigureView < handle

    properties ( GetAccess = public, SetAccess = immutable )
        Root
        Title
        InitialMessage
    end

    properties ( Dependent, SetAccess = private )
        IsCancelled( 1, 1 )logical
    end

    properties ( Access = private )
        Dialog matlab.ui.dialog.ProgressDialog
    end

    properties ( GetAccess = private, SetAccess = immutable )
        MessageService message.internal.MessageService
        UpdateSubscription message.internal.Subscription
        CloseSubscription message.internal.Subscription
    end

    methods
        function this = FigureView( root, uniqueName, options )
            arguments
                root( 1, 1 ){ mustBeA( root, [ "matlab.ui.Figure", "matlab.ui.container.internal.AppContainer" ] ) }
                uniqueName( 1, 1 )string{ mustBeNonzeroLengthText }
                options.Title( 1, 1 )string{ mustBeNonzeroLengthText } = getString( message( "MATLAB:dependency:widgets:ProgressTitle" ) );
                options.InitialMessage( 1, 1 )string{ mustBeNonzeroLengthText } = getString( message( "MATLAB:dependency:widgets:ProgressWaitingForMATLAB" ) );
            end

            this.Root = root;
            this.Title = options.Title;
            this.InitialMessage = options.InitialMessage;

            channel = "/dependency/widget/progress/" + uniqueName;
            this.MessageService = message.internal.MessageService( 'ProjectUpgrade' );
            this.UpdateSubscription = this.MessageService.subscribe( char( channel + "/update" ), @this.update );
            this.CloseSubscription = this.MessageService.subscribe( char( channel + "/close" ), @this.close );
            this.MessageService.publish( char( channel + "/clientConnected" ), '' );
        end

        function cancelled = get.IsCancelled( this )
            cancelled = ~isempty( this.Dialog ) && this.Dialog.CancelRequested;
        end

        function show( this )
            dialog.message = this.InitialMessage;
            dialog.canCancel = false;
            dialog.progressPercentage =  - 1;
            this.update( dialog );
        end

        function close( this )
            if ~isempty( this.Dialog )
                this.Dialog.close(  );
                this.Dialog = matlab.ui.dialog.ProgressDialog.empty( 1, 0 );
            end
        end
    end

    methods ( Access = private )
        function update( this, dialog )
            if isempty( this.Dialog )
                this.Dialog = uiprogressdlg(  ...
                    this.Root,  ...
                    Title = this.Title );
            end

            this.Dialog.Message = dialog.message;
            this.Dialog.Cancelable = dialog.canCancel;
            this.Dialog.Indeterminate = dialog.progressPercentage < 0;
            if ~this.Dialog.Indeterminate
                this.Dialog.Value = dialog.progressPercentage / 100;
            end
        end
    end

end

