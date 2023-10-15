





























































classdef View

    properties ( Dependent )
        Name;
        ReqFilter;
        LinkFilter;
    end

    properties ( Dependent, GetAccess = public, SetAccess = private )
        Host;
    end

    properties ( Access = private, Hidden )
        view;
    end

    methods ( Static )
        function view = create( name, reqset, viewToCopy )
            arguments
                name
                reqset = ''
                viewToCopy = [  ];
            end

            if isempty( name )
                error( message( 'Slvnv:slreq:FilteredViewNameEmpty' ) );
            end

            vm = slreq.app.ViewManager.get;
            cName = convertStringsToChars( name );
            if isempty( reqset )
                iview = vm.createView( cName );
            else
                iview = vm.createView( cName, slreq.gui.View.SET, reqset );
            end

            if isempty( iview )
                error( message( 'Slvnv:rmipref:InvalidArgument', reqset ) );
            end

            if ~isempty( viewToCopy ) && viewToCopy.isValid

            end

            view = slreq.View( iview );
        end

        function views = getViews( name, host )
            arguments
                name = ''
                host = '__any__';
            end

            vm = slreq.app.ViewManager.get;
            if ~isempty( host ) && ~strcmp( host, '__any__' )
                if strcmp( host, prefdir )
                    host = '';
                else
                    rs = slreq.find( 'type', 'ReqSet', 'name', host );
                    if ~isempty( rs )
                        host = rs.Filename;
                    end
                end
            end
            vs = vm.getViews( name, host );
            views = slreq.View.empty;
            for i = 1:numel( vs )
                views( end  + 1 ) = vs( i );
            end
        end

        function view = getActiveView(  )
            vm = slreq.app.ViewManager.get(  );
            view = slreq.View( vm.getCurrentView(  ) );
        end

        function activateDefaultView(  )
            vm = slreq.app.ViewManager.get(  );
            vm.setVanilaAsCurrent;
        end
    end

    methods ( Access = protected )
        function this = View( realView )
            this.view = realView;
        end
    end

    methods
        function n = get.Name( this )
            if this.isValid( true )
                if this.view.isVanillaView
                    n = 'default view';
                else
                    n = this.view.name;
                end
            end
        end
        function this = set.Name( this, n )
            this.errorIfVanilla;
            if isempty( n )
                error( message( 'Slvnv:slreq:FilteredViewNameEmpty' ) );
            else
                this.view.name = convertStringsToChars( n );
            end
        end
        function f = get.ReqFilter( this )
            if this.isValid( true )
                f = this.view.getQuery;
            end
        end
        function this = set.ReqFilter( this, f )
            this.errorIfVanilla;
            this.view.setQuery( convertStringsToChars( f ) );
            this.view.update(  );
        end

        function f = get.LinkFilter( this )
            if this.isValid( true )
                f = this.view.getQuery( false );
            end
        end
        function this = set.LinkFilter( this, f )
            this.errorIfVanilla;
            this.view.setQuery( convertStringsToChars( f ), false );
        end

        function h = get.Host( this )
            if this.isValid( true )
                h = this.view.hostArtifact;
            end
        end
    end

    methods
        function err = getErrorMessage( this )
            if this.isValid( true )
                err = this.view.getLastErrors;
            end
        end

        function activate( this )
            if ~isempty( this.view ) && isvalid( this.view )
                vm = slreq.app.ViewManager.get(  );
                vm.setCurrentView( this.view );
            else
                error( message( 'Slvnv:slreq:InvalidView', this.Name ) );
            end
        end

        function this = delete( this )
            if this.isValid
                vm = slreq.app.ViewManager.get(  );
                vm.deleteView( this.view );
                this.view = slreq.gui.View.empty;
            end
        end

        function tf = isValid( this, throwErr )
            arguments
                this
                throwErr = false;
            end

            tf = true;
            vm = slreq.app.ViewManager.get(  );
            if ~vm.isValidView( this.view )
                if throwErr
                    error( message( 'Slvnv:slreq:InvalidView', this.Name ) );
                else
                    tf = false;
                end
            end
        end
    end

    methods ( Access = private, Hidden )
        function errorIfVanilla( this )
            if this.isValid( true ) && this.view.isVanillaView
                error( message( 'Slvnv:slreq:CannotChangeDefaultView' ) );
            end
        end

    end
end
