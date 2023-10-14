function handle = displayRename( graph, oldPath, newPath,  ...
    analysisWasCancelled, renameAction, debug )

arguments
    graph( 1, 1 )dependencies.internal.graph.Graph;
    oldPath( 1, 1 )string{ mustBeNonzeroLengthText };
    newPath( 1, 1 )string{ mustBeNonzeroLengthText };
    analysisWasCancelled( 1, 1 )logical;
    renameAction( 1, 1 )dependencies.internal.refactoring.Action;
    debug( 1, 1 )logical = false;
end

import dependencies.internal.refactoring.root.makeFileRename;
import dependencies.internal.refactoring.root.makeFolderRename;
import dependencies.internal.refactoring.root.makeNamespaceRename;

model = mf.zero.Model;

if isfile( oldPath )
    oldNode = dependencies.internal.graph.Node.createFileNode( oldPath );
    showManualRefactoring = analysisWasCancelled || i_isAtClassConstructor( oldPath );
    root = makeFileRename( model, graph, oldNode, newPath,  ...
        ~showManualRefactoring, renameAction );
elseif ~isfolder( oldPath )
    root = dependencies.internal.refactoring.Root.empty;
elseif i_isNamespaceFolder( oldPath )
    root = makeNamespaceRename( model, graph, oldPath, newPath, renameAction );
else
    root = makeFolderRename( model, graph, oldPath, newPath,  ...
        ~analysisWasCancelled, renameAction );
end

if isempty( root )
    if nargout > 0
        handle = dependencies.internal.refactoring.App.empty;
    end
    renameAction.apply(  );
    return ;
end

manager = dependencies.internal.refactoring.TaskManager( root );

app = dependencies.internal.refactoring.App( model, manager, Debug = debug );

if nargout > 0
    handle = app;
    app.launch(  );
else
    wm = dependencies.internal.widget.WindowManager.Instance;
    wm.launchAndRegister( app );
end
end

function isAtClassConstructor = i_isAtClassConstructor( file )
arguments
    file( 1, 1 )string;
end
[ parentPath, fileName, ext ] = fileparts( file );
[ ~, parentName, parentExt ] = fileparts( parentPath );
parentName = parentName + parentExt;

isAtClassConstructor = ext == ".m" && parentName == "@" + fileName;
end

function isNamespace = i_isNamespaceFolder( path )
[ ~, folderName ] = fileparts( path );
isNamespace = startsWith( folderName, [ "+", "@" ] );
end

