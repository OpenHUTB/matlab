classdef Importer < handle
    properties
        App;
    end

    properties ( Access = private )
        success;
        refreshData;
    end

    methods
        function obj = Importer( app )
            obj.App = app;
        end


        function import( obj, actionInfo )
            success = true;
            if strcmp( actionInfo.addType, 'AddFolder' )
                path = obj.App.getFilePath(  );
                if isempty( path )
                    path = pwd;
                end
                folder = uigetdir( path, message( 'classdiagram_editor:messages:CBSelectFolder_Prompt' ).string );
                if ischar( folder )
                    [ success, refreshData ] = obj.importInternal( actionInfo.addType, folder,  ...
                        actionInfo.runAddCommand );
                else
                    refreshData = struct(  );
                end
                obj.App.raise(  );
            elseif strcmp( actionInfo.addType, 'AddProject' )
                [ success, refreshData ] = obj.importInternal( actionInfo.addType, '',  ...
                    actionInfo.runAddCommand );
                actionInfo.type = "importCurrentProject";
            else
                [ success, refreshData ] = obj.importInternal( actionInfo.addType, actionInfo.fullName,  ...
                    actionInfo.runAddCommand );
            end
            if ~isempty( fieldnames( refreshData ) )
                obj.App.refresher.refresh( refreshData );
            end
            actionInfo.action = 'import';
            obj.App.publishResponse( actionInfo, success );
        end
    end

    methods ( Access = { ?classdiagram.app.core.ClassDiagramApp,  ...
            ?matlab.diagram.ClassViewer } )
        function [ success, refreshData ] = importInternal( obj, addType, addName,  ...
                runAddCommand, recurse )
            arguments
                obj( 1, 1 )classdiagram.app.core.Importer;
                addType( 1, : )char{ mustBeMember( addType, { 'AddClass', 'AddPackage', 'AddFolder', 'AddProject' } ) };
                addName( 1, : )string;
                runAddCommand( 1, 1 )logical;
                recurse( 1, 1 )logical = true;
            end




            function [ success, refreshData ] = inner( obj, addType, addName,  ...
                    runAddCommand, recurse )
                success = true;
                rootExists = false;
                id = string.empty;
                cb = obj.App.getClassBrowser;
                if isa( obj.App.notifier, 'classdiagram.app.core.notifications.Notifier' )



                    obj.App.notifier.setMode( classdiagram.app.core.notifications.Mode.WAIT );
                end
                switch addType
                    case 'AddClass'
                        if isfile( addName )

                            m = mtree( addName, '-file' );
                            if m.FileType == mtree.Type.ClassDefinitionFile
                                addName = classdiagram.app.core.domain.Folder.getClassFullName( addName );
                            else
                                success = false;
                                refreshData = struct.empty;
                                return ;
                            end
                        end
                        id = classdiagram.app.core.utils.ObjectIDUtility.generateClassID( addName );
                        rootExists = success && cb.rootNodeExists( id );
                        if ~rootExists

                            id = classdiagram.app.core.utils.ObjectIDUtility.generateEnumID( addName );
                            rootExists = cb.rootNodeExists( id );
                        end
                        if ~rootExists
                            success = cb.DataProvider.addRootClassOrEnum( addName, warn = ~runAddCommand );
                        end
                        if runAddCommand
                            toLayout = true;
                            obj.App.addClassInternal( addName, toLayout );
                        end
                    case 'AddPackage'
                        id = classdiagram.app.core.utils.ObjectIDUtility.generatePackageID( addName );
                        rootExists = cb.rootNodeExists( id );
                        if ~rootExists
                            success = cb.DataProvider.addRootPackages( { addName }, warn = ~runAddCommand );
                        end
                        if runAddCommand
                            obj.App.addPackageInternal( addName, recurse );
                        end
                    case 'AddFolder'
                        id = classdiagram.app.core.utils.ObjectIDUtility.generateFolderID( addName );
                        rootExists = cb.rootNodeExists( id );
                        if ~rootExists
                            cb.DataProvider.addRootFolders( { addName }, warn = ~runAddCommand );
                        end
                        if runAddCommand
                            obj.App.addFolderInternal( addName, recurse );
                        end
                    case 'AddProject'
                        try
                            p = currentProject;
                            id = classdiagram.app.core.utils.ObjectIDUtility.generateProjectID( p.RootFolder );
                            rootExists = cb.rootNodeExists( id );
                            if ~rootExists
                                cb.DataProvider.addRootProjects( { p.RootFolder }, warn = ~runAddCommand );
                            end
                            if runAddCommand
                                obj.App.addProjectInternal( p.RootFolder );
                            end
                        catch e
                            success = false;


                            rootNodes = cb.getRootNodes;
                            idx = cellfun( @( o )strcmp( o.getType, "Project" ), rootNodes );
                            if any( idx )
                                p = rootNodes( idx );
                                id = p{ : }.getObjectID;
                                rootExists = true;
                            end
                            if isa( obj.App.notifier, 'classdiagram.app.core.notifications.Notifier' )
                                obj.App.notifier.processNotification( e );
                            else
                                obj.App.notifier.processNotification(  ...
                                    classdiagram.app.core.notifications.notifications.MExceptionNotification(  ...
                                    e ) );
                            end
                        end
                    otherwise
                        success = false;
                        if isa( obj.App.notifier, 'classdiagram.app.core.notifications.Notifier' )
                            obj.App.notifier.processNotification(  ...
                                'ErrMNotSupported', string( addType ) );
                        else
                            obj.App.notifier.processNotification(  ...
                                classdiagram.app.core.notifications.notifications.ErrMNotSupported(  ...
                                string( addType ) ) );
                        end
                end
                if rootExists
                    refreshData = struct( 'id', id );
                else
                    refreshData = struct.empty;

                    if isa( obj.App.notifier, 'classdiagram.app.core.notifications.Notifier' )
                        obj.App.notifier.doneWaiting(  );
                    end
                end
                obj.success = success;
                obj.refreshData = refreshData;
            end
            fh = @( batchOps )inner( obj, addType, addName,  ...
                runAddCommand, recurse );
            obj.App.executeAction( fh, Action = 'import' );
            success = obj.success;
            refreshData = obj.refreshData;
        end
    end
end


