function views = getRegisteredViews( refresh )

arguments
    refresh logical = false;
end

persistent REGISTERED_VIEWS REGISTERED_VIEW_FCNS;

if isempty( REGISTERED_VIEWS ) || refresh
    [ REGISTERED_VIEWS, REGISTERED_VIEW_FCNS ] = parseRegistryFiles(  );
end

try
    n = numel( REGISTERED_VIEW_FCNS );
    fcnViews = cell( 1, n );
    for i = 1:n
        fcnViews{ i } = createViewFromFunction( REGISTERED_VIEW_FCNS{ i } );
    end
catch


    [ REGISTERED_VIEWS, REGISTERED_VIEW_FCNS ] = parseRegistryFiles(  );
    n = numel( REGISTERED_VIEW_FCNS );
    fcnViews = cell( 1, n );
    for i = 1:n
        try
            fcnViews{ i } = createViewFromFunction( REGISTERED_VIEW_FCNS{ i } );
        catch ME
            fcnViews{ i } = [  ];
            warning( ME.message );
        end
    end
end

views = [ REGISTERED_VIEWS, fcnViews ];
views( cellfun( 'isempty', views ) ) = [  ];
end

function [ views, fcns ] = parseRegistryFiles(  )
registryFiles = which( "webview_registry.xml", "-all" );
views = {  };
fcns = {  };
parser = matlab.io.xml.dom.Parser(  );

for i = 1:numel( registryFiles )
    registryFile = registryFiles{ i };
    d = parser.parseFile( registryFile );

    mustBeValidWebViewRegistry( d );

    viewList = d.getElementsByTagName( "view" );
    for j = 1:viewList.getLength(  )
        viewElement = viewList.item( j - 1 );


        if viewElement.hasAttribute( "exporter" )
            view = createViewFromClass( viewElement );
            views = [ views, { view } ];%#ok<AGROW>

        elseif viewElement.hasAttribute( "fcn" )
            fcn = getViewCreateFunction( viewElement );
            fcns = [ fcns, { fcn } ];%#ok<AGROW>
        end
    end
end
end

function mustBeValidWebViewRegistry( d )
xpath = matlab.io.xml.xpath.Evaluator(  );
rootElement = xpath.evaluate( "/webview_registry", d );
if ~isempty( rootElement )
    if ~rootElement.hasAttribute( "version" )
        error( message( "slreportgen_webview:exporter:WebViewRegistryVersionMissing",  ...
            registryFile ) );
    end
else
    error( message( "slreportgen_webview:exporter:WebViewRegistryRegistryMissing",  ...
        registryFile ) );
end
end

function view = createViewFromClass( viewElement )
constructor = viewElement.getAttribute( "exporter" );
if isempty( constructor )
    error( message( "slreportgen_webview:exporter:WebViewRegistryViewExporterMissing",  ...
        registryFile ) );
end


try
    view = eval( constructor );
catch ME
    error( message( "slreportgen_webview:exporter:ViewExporterInstantiationError",  ...
        constructor, registryFile, ME.message ) );
end

if ~isa( view, "slreportgen.webview.ViewExporter" )
    error( message( "slreportgen_webview:exporter:WebViewRegistryNotViewExporter",  ...
        class( view ) ) );
end

if isempty( view.Id )
    error( message( "slreportgen_webview:exporter:ViewExporterMissingId",  ...
        constructor ) );
end
end

function fcn = getViewCreateFunction( viewElement )
fcn = viewElement.getAttribute( "fcn" );
if isempty( fcn )
    error( message( 'slreportgen_webview:exporter:WebViewRegistryViewExporterFcnMissing',  ...
        registryFile ) );
end
end

function view = createViewFromFunction( fcn )
view = feval( fcn );
if ~isa( view, "slreportgen.webview.ViewExporter" )
    error( message( 'slreportgen_webview:exporter:WebViewRegistryNotViewExporter', class( exporter ) ) );
end

if isempty( view.Id )
    error( message( 'slreportgen_webview:exporter:ViewExporterMissingId',  ...
        fcn ) );
end
end


