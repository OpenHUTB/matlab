function launchSimBiologyApp( appType, modelOrProject, options )

arguments
    appType( 1, 1 )string{ mustBeMember( appType, [ "builder", "analyzer" ] ) }
    modelOrProject = string( missing )
    options.UseBrowser( 1, 1 )logical = false
    options.Debug( 1, 1 )logical
    options.Show( 1, 1 )logical = true
end

model = missing;
projectName = missing;
if nargin == 1

elseif isa( modelOrProject, "SimBiology.Model" )

    model = modelOrProject;
    SimBiology.internal.mustBeValidModel( model, 'SimBiology:apps:InvalidModelOrProject' );
else

    projectName = validateAndStandardizeProjectName( modelOrProject );
    projectName = getfullpath( projectName );
end
if ~isfield( options, 'Debug' )

    options.Debug = options.UseBrowser;
end



mb = SimBiology.web.desktophandler( 'getModelBuilder' );
ma = SimBiology.web.desktophandler( 'getModelAnalyzer' );
if ~( isempty( mb.webWindow ) && isempty( ma.webWindow ) ) &&  ...
        ~( ismissing( projectName ) && ismissing( model ) )
    error( message( 'SimBiology:apps:NoModelOrProjectIfAppOpen' ) );
end


url = getURL( appType, model, projectName, options.Debug );

if options.UseBrowser
    web( url, '-browser' )
else
    launchWebWindow( appType, url, options.Show );
end

end

function url = getURL( appType, model, projectName, debug )


connector.ensureServiceOn;

if appType == "builder"
    urlDir = "/toolbox/simbio/web/modelingapp/";
else
    urlDir = "/toolbox/simbio/web/analysisapp/";
end

if debug
    page = "index-debug.html";
else
    page = "index.html";
end

url = connector.getUrl( urlDir + page );

if ~ismissing( projectName )
    url = url + "&name=" + projectName;
end
if ~ismissing( model )
    url = url + "&model=" + model.SessionID;
end

end

function launchWebWindow( appType, url, show )

if appType == "builder"
    handler = 'getModelBuilder';
else
    handler = 'getModelAnalyzer';
end

out = SimBiology.web.desktophandler( handler );
webWindow = out.webWindow;
title = out.title;

if isempty( webWindow )
    screensize = get( 0, 'ScreenSize' );
    x = floor( 0.1 * screensize( 3 ) );
    y = floor( 0.1 * screensize( 4 ) );
    width = ceil( 0.75 * screensize( 3 ) );
    height = ceil( 0.75 * screensize( 4 ) );
    webWindow = matlab.internal.webwindow( url, matlab.internal.getDebugPort, [ x, y, width, height ] );
    webWindow.Title = title;

    minWidth = 920;
    if ( width < minWidth )
        minWidth = ceil( 0.5 * screensize( 3 ) );
    end

    minHeight = 560;
    if ( height < minHeight )
        minHeight = ceil( 0.5 * screensize( 4 ) );
    end

    setMinSize( webWindow, [ minWidth, minHeight ] );
end

if show
    webWindow.show;
    webWindow.bringToFront;
end

end

function projectName = validateAndStandardizeProjectName( projectName )

try
    mustBeTextScalar( projectName );
    mustBeNonzeroLengthText( projectName );
catch
    error( message( 'SimBiology:apps:InvalidModelOrProject' ) );
end
projectName = convertStringsToChars( projectName );

end

function fullfilename = getfullpath( name )

out = SimBiology.web.desktophandler( 'getfullpath', name );

id = out.id;
msg = out.msg;
fullfilename = string( out.fullfilename );

if ~isempty( id )
    error( id, msg );
end

end
