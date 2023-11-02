% doc matlab.diagram.ClassViewer
classdef ( Sealed )ClassViewer < handle

    properties ( Transient = true, SetAccess = private, GetAccess = { ?classDiagramTest.ClassDiagramTestCase } )
        App classdiagram.app.core.ClassDiagramApp = classdiagram.app.mcos.MCOSApp.empty;
    end


    properties (Dependent, Transient = true)
        Visible( 1, 1 )logical;
        ActiveFile string;
        ClassesInDiagram string;
        ShowPackageNames( 1, 1 )logical;
        ShowMixins( 1, 1 )logical;
    end


    methods
        function value = get.Visible( self )
            value = self.getApp.isVisible(  );
        end


        function set.Visible(self, value)
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                value( 1, 1 )matlab.lang.OnOffSwitchState
            end
            if value
                self.getApp.show();
            else
                self.getApp.close();
            end
        end


        function value = get.ShowPackageNames( self )
            value = self.getApp.IsShowPackageNames;
        end


        function set.ShowPackageNames( self, value )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                value( 1, 1 )matlab.lang.OnOffSwitchState
            end
            app = self.getApp;
            app.IsShowPackageNames = logical(value);
        end

        function value = get.ShowMixins(self)
            value = self.getApp.IsShowMixins;
        end

        function set.ShowMixins(self, value)
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                value( 1, 1 )matlab.lang.OnOffSwitchState
            end
            app = self.getApp;
            app.IsShowMixins = logical( value );
        end

        function value = get.ActiveFile( self )
            value = self.getApp.getFilePath(  );
        end

        function value = get.ClassesInDiagram( self )
            value = sort( self.getApp.getAllElementNames(  ) );
        end

        function self = ClassViewer( optional )

            arguments
                optional.Visible( 1, 1 )matlab.lang.OnOffSwitchState = true;
                optional.Load string{ mustBeScalarOrEmpty };
                optional.Classes( 1, : ){ mustBeClassOrString };
                optional.Folders( 1, : )string;
                optional.Packages( 1, : )string;
                optional.IncludeSubfolders( 1, 1 )matlab.lang.OnOffSwitchState = true;
                optional.IncludeSubpackages( 1, 1 )matlab.lang.OnOffSwitchState = true;
            end
            app = self.getApp;
            if optional.Visible
                app.show(  );
                app.notifier.setMode(  ...
                    classdiagram.app.core.notifications.Mode.UI,  ...
                    classdiagram.app.core.notifications.Mode.WAIT );
            end
            if isfield( optional, "Load" )
                self.load( optional.Load );
            else
                self.importClassesFromStruct( optional );
            end
            app.notifier.resetMode(  );
        end
    end


    methods
        function eql = eq( self, other )
            eql = [ self.App ] == [ other.App ];
        end

        function neql = ne( self, other )
            neql = ~self.eq( other );
        end


        function addClass( self, classes )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                classes( 1, : ){ mustBeClassOrString };
            end
            self.importClassesFrom( "Classes", classes );
        end

        
        function importClassesFrom( self, options )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                options.Classes( 1, : ){ mustBeClassOrString };
                options.Folders( 1, : )string;
                options.Packages( 1, : )string;
                options.IncludeSubfolders( 1, 1 )matlab.lang.OnOffSwitchState = true;
                options.IncludeSubpackages( 1, 1 )matlab.lang.OnOffSwitchState = true;
            end
            self.importClassesFromStruct( options );
        end

        function importCurrentProject( self )
            app = self.getApp(  );
            addToCanvas = true;

            [ ~, refreshData ] = app.importer.importInternal( 'AddProject', '', addToCanvas );

            if ~isempty( fieldnames( refreshData ) )
                app.refresher.refresh( refreshData );
            else
                app.syntax.modify( @( ops )app.doLayout( ops ) );
            end
        end

        function removeClass( self, classes )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                classes( 1, : ){ mustBeClassOrString };
            end
            classes = classOrStringToStringArray( classes );
            cp = self.getApp.editor.commandProcessor;
            cmd = cp.createCustomCommand( 'classdiagram.app.core.commands.ClassDiagramDeleteCommand',  ...
                'remove', struct( "elements", classes ) );
            try
                cp.execute( cmd );
            catch e %#ok<NASGU>

            end
        end

        function removeAllClasses( self )
            elements = self.getApp.getAllElementNames;
            if ~isempty( elements )
                self.removeClass( self.getApp.getAllElementNames );
            end
        end

        function expandAll( self, expanded )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                expanded( 1, 1 ){ mustBeNumericOrLogical } = true;
            end
            self.getApp.expandAll( expanded );
        end

        function expandClass( self, classes, expanded )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                classes( 1, : ){ mustBeClassOrString };
                expanded( 1, 1 ){ mustBeNumericOrLogical } = true;
            end
            classes = classOrStringToStringArray( classes );
            self.getApp.expandClass( classes, expanded );
        end

        function expandSection( self, classes, section, expanded )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                classes( 1, : ){ mustBeClassOrString };
                section( 1, 1 )string;
                expanded( 1, 1 ){ mustBeNumericOrLogical } = true;
            end
            classes = classOrStringToStringArray( classes );
            self.getApp.expandSection( classes, section, expanded );
        end

        function load( self, fileName )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                fileName string{ mustBeScalarOrEmpty } = string.empty;
            end

            if isempty( fileName ) && isempty( self.ActiveFile )
                error( message( 'classdiagram_editor:messages:ErrMNoActiveFile' ) );
            end

            self.getApp.notifier.setMode(  ...
                classdiagram.app.core.notifications.Mode.UI );
            self.getApp.loadDiagram( fileName );
        end

        function save( self, fileName )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                fileName string{ mustBeScalarOrEmpty } = string.empty;
            end

            if isempty( fileName ) && isempty( self.ActiveFile )
                error( message( 'classdiagram_editor:messages:ErrMNoActiveFile' ) );
            end

            self.getApp.saveDiagram( fileName );
        end

        function export( self, fileName, options )
            arguments
                self( 1, 1 )matlab.diagram.ClassViewer;
                fileName( 1, 1 )string{ mustBeNonzeroLength, mustBeNonfolder };


                options.Format( 1, 1 )string{  ...
                    mustBeMember( options.Format, { 'JPG', 'PDF', 'PNG',  ...
                    'jpg', 'pdf', 'png' } ) };
                options.Size( 1, 2 )double;
            end

            exportArgs = struct( filename = fileName );
            if isfield( options, "Size" ) && ~isempty( options.Size )
                exportArgs.size = options.Size;
            end
            if isfield( options, "Format" )
                exportArgs.format = lower( options.Format );
            end

            self.getApp.export( exportArgs );

        end

    end

    methods ( Access = { ?classDiagramTest.ClassDiagramTestCase, ?classdiagram.app.core.ProjectLaunchManager,  ...
            ?classdiagram.app.core.ClassDiagramLaunchManager } )
        function setApp( self, app )
            self.App = app;
        end

        function app = getApp( self )
            self.ensureAppCreated(  );
            app = self.App;
        end

        function ensureAppCreated( self )
            if isempty( self.App )
                self.setApp( classdiagram.app.mcos.MCOSApp(  ) );
            end
        end

        function importClassesFromStruct( self, toAdd )
            hasAdditions = isfield( toAdd, "Classes" ) ||  ...
                isfield( toAdd, "Folders" ) ||  ...
                isfield( toAdd, "Packages" );
            if ~hasAdditions
                return ;
            end

            if isfield( toAdd, "Classes" )
                toAdd.Classes = classOrStringToStringArray( toAdd.Classes );
            end

            app = self.getApp(  );
            app.syntax.modify( @( ops )self.addAdditions( ops, toAdd ) );
        end

        function addAdditions( self, ops, add )
            app = self.getApp(  );
            refreshData = struct(  );
            direction = 'descend';
            if isa( app.notifier, 'classdiagram.app.core.notifications.Notifier' )



                app.notifier.setMode(  ...
                    classdiagram.app.core.notifications.Mode.WAIT );
            end
            if isfield( add, 'Visible' ) && add.Visible
                app.notifier.setMode(  ...
                    classdiagram.app.core.notifications.Mode.UI );
            end

            function cdImport( addType, addName, recurse )
                addToCanvas = true;
                [ ~, r ] = app.importer.importInternal( addType, addName, addToCanvas, recurse );
                if ~isempty( r )
                    refreshData = r;
                end
            end

            if isfield( add, "Classes" )
                recurse = false;
                classes = classdiagram.app.core.utils.sortNames( add.Classes, direction );
                if isempty( classes )
                    if isa( app.notifier, 'classdiagram.app.core.notifications.Notifier' )
                        app.notifier.processNotification( 'ErrMInvalidMCOSClass', "" );
                    else
                        app.notifier.processNotification(  ...
                            classdiagram.app.core.notifications.notifications.ErrMInvalidMCOSClass( "" ) );
                    end
                end
                arrayfun( @( cls )cdImport( 'AddClass', cls, recurse ), classes );
            end
            if isfield( add, "Packages" )
                packages = classdiagram.app.core.utils.sortNames( add.Packages, direction );
                arrayfun( @( cls )cdImport( 'AddPackage', cls, logical( add.IncludeSubpackages ) ), packages );
            end
            if isfield( add, "Folders" )
                add.Folders = regexprep( add.Folders, '/$', '' );
                folders = classdiagram.app.core.utils.sortNames( add.Folders, direction );
                arrayfun( @( cls )cdImport( 'AddFolder', cls, logical( add.IncludeSubfolders ) ), folders );
            end

            if ~isempty( fieldnames( refreshData ) )
                app.refresher.refresh( refreshData );
            else
                app.doLayout( ops );
            end
        end
    end

    methods ( Static, Access = private )
        function self = createClassViewer( app )
            self = matlab.diagram.ClassViewer( 'Visible', false );
            self.setApp( app );
        end
    end

    methods ( Static )
        function windows = getAllViewers(  )
            wm = classdiagram.app.core.WindowManager.Instance;
            apps = wm.getOpenWindows(  );
            windows = arrayfun( @matlab.diagram.ClassViewer.createClassViewer, apps );
        end

        function windows = getVisibleViewers(  )
            windows = matlab.diagram.ClassViewer.getAllViewers;
            if ~isempty( windows )
                windows = windows( [ windows.Visible ] );
            end
        end
    end
end

function str = classOrCharToString( arg )
if isa( arg, "meta.class" )
    str = string( arg.Name );
elseif isstring( arg )
    str = arg;
elseif ischar( arg )
    str = string( arg );
else
    cls = metaclass( arg );
    str = string( cls.Name );
end
end

function arr = classOrStringToStringArray( args )
if isempty( args )
    arr = string.empty;
    return ;
end
if iscell( args )
    arr = cellfun( @( arg )classOrCharToString( arg ), args );
    return ;
end
if ischar( args )
    arr = string( args );
    return ;
end
arr = arrayfun( @( arg )classOrCharToString( arg ), args );
end


function mustBeClassOrString( arg )
if ~( isa( arg, "char" ) || isa( arg, "string" ) || isa( arg, "cell" ) || isa( arg, "meta.class" ) )
    return ;
end
try
    cls = metaclass( arg );%#ok<NASGU>
catch e
    eidType = 'classdiagram_editor:messages:ErrMNotStringOrClass';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) )
end
end

function mustBeNonzeroLength( arg )
if ~strlength( arg )
    eidType = 'classdiagram_editor:messages:MissingExportFile';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) );
end
end

function mustBeNonfolder( arg )
if isfolder( arg )
    eidType = 'diagram_editor_registry:General:FilenameIsFolder';
    msgType = message( eidType );
    throwAsCaller( MException( eidType, msgType ) );
end
end


