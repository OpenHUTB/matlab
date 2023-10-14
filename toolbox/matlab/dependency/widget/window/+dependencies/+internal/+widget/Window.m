classdef Window < handle











    properties ( SetAccess = immutable )
        Title;
        Tag;
    end

    properties ( GetAccess = private, SetAccess = immutable )
        BaseURL;
    end

    properties ( Access = private )
        WebWindow( 1, : )matlab.internal.webwindow = matlab.internal.webwindow.empty(  );
        TargetPosition( 1, 4 );
        MinimumSize( 1, 2 );
    end

    events
        Closed
    end

    methods
        function this = Window( baseURL, title, initialSize, minimumSize, tag )
            arguments
                baseURL( 1, : )char{ mustBeNonempty };
                title( 1, 1 )string;
                initialSize( 1, 2 )double{ mustBePositive };
                minimumSize( 1, 2 )double{ mustBePositive };
                tag( 1, 1 )string;
            end

            this.BaseURL = baseURL;

            this.Tag = tag;
            this.Title = title;

            this.TargetPosition = i_getPosition( initialSize( 1 ), initialSize( 2 ), 0.8 );
            this.MinimumSize = min( minimumSize, this.TargetPosition( 3:4 ) );
        end

        function resize( this, newWidth, newHeight )
            if this.isVisible(  )
                [ previousCenterX, previousCenterY ] = this.getTopCenter(  );
            else


                previousCenterX = NaN;
                previousCenterY = NaN;
            end
            this.TargetPosition = i_getPosition( newWidth, newHeight, 0.8,  ...
                previousCenterX, previousCenterY );
            this.WebWindow.Position = this.TargetPosition;
        end

        function show( this )
            if isempty( this.WebWindow )
                this.createWebWindow(  )
            end
            this.makeUserVisible(  );
        end

        function delete( this )
            this.close(  );
        end

        function url = getUrl( this )
            connector.ensureServiceOn(  );
            url = connector.getUrl( this.BaseURL );
        end

        function size = getSize( this )
            size = this.WebWindow.Position( 3:4 );
        end

        function visible = isVisible( this )
            try
                visible = ~isempty( this.WebWindow ) &&  ...
                    this.WebWindow.isWindowValid &&  ...
                    this.WebWindow.isVisible;
            catch me
                if "MATLAB:class:InvalidHandle" ~= me.identifier
                    me.rethrow(  );
                end


                visible = false;
            end
        end

        function close( this )
            if ~isempty( this.WebWindow )
                oldWindow = this.WebWindow;
                this.WebWindow = matlab.internal.webwindow.empty(  );
                oldWindow.close(  )
                this.notify( 'Closed' );
            end
        end
    end

    methods ( Hidden )
        function [ x, y ] = getTopCenter( this )
            [ x, y ] = i_getTopCenter( this.WebWindow.Position );
        end

        function launchDevTools( this )
            if isempty( this.WebWindow )
                error( "The window was not started, call makeUserVisible first" )
            else
                this.WebWindow.executeJS( 'cefclient.sendMessage("openDevTools");' )
            end
        end
    end

    methods ( Access = private )
        function createWebWindow( this )
            urlWithNonce = this.getUrl(  );
            this.WebWindow = matlab.internal.webwindow( urlWithNonce );

            if ~ismissing( this.Tag )
                this.WebWindow.Tag = char( this.Tag );
            end

            if ~ismissing( this.Title )
                this.WebWindow.Title = char( this.Title );
            end

            this.WebWindow.Position = this.TargetPosition;
            this.WebWindow.CustomWindowClosingCallback = @( varargin )this.close(  );
            this.WebWindow.MATLABWindowExitedCallback = @( varargin )this.close(  );
            this.WebWindow.setMinSize( this.MinimumSize );
        end

        function makeUserVisible( this )
            if this.WebWindow.isMinimized(  )
                this.WebWindow.restore(  );
            end
            this.WebWindow.bringToFront(  );
        end

    end

end

function position = i_getPosition( width, height, ratio, topCenterX, topCenterY )
arguments
    width( 1, 1 )double
    height( 1, 1 )double
    ratio( 1, 1 )double
    topCenterX( 1, 1 )double = NaN
    topCenterY( 1, 1 )double = NaN
end

screen = i_getScreenSize(  );

window.Width = min( screen.Width * ratio, width );
window.Height = min( screen.Height * ratio, height );

if isnan( topCenterX )
    topCenterX = screen.Width / 2;
end
if isnan( topCenterY )
    topCenterY = ( screen.Height + window.Height ) / 2;
end

x = topCenterX - window.Width / 2;
y = topCenterY - window.Height;

position = [ x, y, window.Width, window.Height ];
end

function screen = i_getScreenSize(  )
initUnits = get( groot, "Units" );
cleanup = onCleanup( @(  )set( groot, Units = initUnits ) );
set( groot, Units = "pixels" );

ss = get( groot, "ScreenSize" );
screen.Width = ss( 3 );
screen.Height = ss( 4 );
end

function [ x, y ] = i_getTopCenter( position )
x = position( 1 ) + position( 3 ) / 2;
y = position( 2 ) + position( 4 );
end

