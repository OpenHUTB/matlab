classdef ( Abstract )AbstractAxesInteractor < matlab.uiautomation.internal.interactors.AbstractComponentInteractor

    methods
        function uicontextmenu( actor, menu, position )
            arguments
                actor
                menu( 1, 1 )matlab.ui.container.Menu{ validateParent }
                position = actor.getDataSpaceCenter(  )
            end

            import matlab.uiautomation.internal.Buttons;

            drawnow nocallbacks;
            xyz = actor.validateCoordinate( position );
            pt = actor.coord2point( xyz );

            [ axesID, container ] = actor.getAxesDispatchData(  );

            button = Buttons.RIGHT;
            actor.Dispatcher.dispatch( container, 'uipress',  ...
                'axesType', 'Axes',  ...
                'axesID', axesID,  ...
                'X', pt( 1 ),  ...
                'Y', pt( 2 ),  ...
                'Z', pt( 3 ),  ...
                'Button', button );

            menuInteractor = matlab.uiautomation.internal.InteractorFactory.getInteractorForHandle( menu );
            menuInteractor.uipress(  );
        end
    end

    methods ( Access = protected )

        function pt = parseCoordinatesAndGetPoint( actor, coord )

            drawnow nocallbacks;

            if nargin == 1
                xyz = actor.getDataSpaceCenter(  );
            else
                xyz = actor.validateCoordinate( coord );
            end

            pt = actor.coord2point( xyz );

        end

        function centerCoords = getDataSpaceCenter( actor )

            ax = actor.Component;


            linCenter = @( lim )mean( lim, 2 );
            logCenter = @( lim )sqrt( lim( :, 1 ) .* lim( :, 2 ) ) .* sign( lim( :, 1 ) );

            [ ~ ] = get( ax );
            [ xyzLims{ 1:3 } ] = matlab.graphics.interaction.internal.getFiniteLimits( ax );
            lims = vertcat( xyzLims{ : } );

            logmask = actor.isLogScale(  );

            centerCoords = zeros( 3, 1 );
            centerCoords( ~logmask ) = linCenter( lims( ~logmask, : ) );
            centerCoords( logmask ) = logCenter( lims( logmask, : ) );
            centerCoords = centerCoords';
        end

        function xyz = validateCoordinate( actor, coord )


            ax = actor.Component;
            validateattributes( coord, { 'numeric' }, { 'row', 'real', 'nonnan', 'finite' } );
            L = length( coord );
            if ~any( L == [ 2, 3 ] )
                error( message( 'MATLAB:uiautomation:Driver:InvalidAxesCoordinate' ) );
            end
            xyz = coord;

            if L == 2
                [ az, ~ ] = view( ax );
                if az == 0
                    xyz( 3 ) = mean( ax.ActiveDataSpace.ZLim );
                else
                    error( message( 'MATLAB:uiautomation:Driver:Invalid3DAxesCoordinate' ) );
                end
            end

            isLog = actor.isLogScale(  );
            if any( isLog )


                limsgn = sign( [ ax.ActiveDataSpace.XLim( 1 ), ax.ActiveDataSpace.YLim( 1 ), ax.ActiveDataSpace.ZLim( 1 ) ] );
                if any( limsgn( isLog ) ~= sign( coord( isLog ) ) )
                    error( message( 'MATLAB:uiautomation:Driver:OutOfBounds' ) )
                end
            end
        end

        function pt = coord2point( actor, coord )

            ax = actor.Component;




            pt = matlab.graphics.internal.transformDataToWorld( ax.ActiveDataSpace, eye( 4 ), coord( : ) );


            if actor.isSSR(  )
                pt = calculateServerSideViewerCoords( ax, pt );
            end
        end

        function [ axesID, container ] = getAxesDispatchData( actor )

            ax = actor.Component;
            axesID = getObjectID( ax );
            container = ancestor( ax, 'matlab.ui.internal.mixin.CanvasHostMixin' );
        end

        function bool = isSSR( actor )
            hCanvasContainer = ancestor( actor.Component,  ...
                'matlab.ui.internal.mixin.CanvasHostMixin' );
            canvas = hCanvasContainer.getCanvas;
            bool = strcmpi( canvas.ServerSideRendering, 'on' );
        end

        function mask = isLogScale( actor )
            ax = actor.Component;
            mask = "log" == { ax.XScale, ax.YScale, ax.ZScale };
        end


    end
end

function pt = calculateServerSideViewerCoords( ax, coord )

mvp = getModelViewProjectionMatrix( ax );
pt = mvp * [ coord( : );1 ];
pt = pt( 1:3 ) ./ pt( 4 );
end

function M = getModelViewProjectionMatrix( a )
vp = matlab.graphics.interaction.internal.getViewProjectionMatrix( a );
M = vp * a.ActiveDataSpace.getMatrix;
end

function validateParent( menu )
if isempty( ancestor( menu, 'matlab.ui.container.ContextMenu' ) )
    error( message( 'MATLAB:uiautomation:Driver:InvalidContextMenuOption' ) );
end
end

