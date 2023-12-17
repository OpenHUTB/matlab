classdef Cad2DCanvas < matlabshared.application.Canvas &  ...
        cad.Cad2DView &  ...
        matlabshared.application.Zoom &  ...
        matlabshared.application.FillAxes &  ...
        cad.MouseBehaviour &  ...
        cad.KeyBoardBehaviour


    properties
        ObjectStack;
        HoverObject;
        SelectedObject
        PolygonDraw
        InteractionMode
        DragStartData
        DragEndData
        RotateStartData
        Center
        UnitsPerPixel
        PanInitialPoint
        SelectionRect
        DrawShapeObj
        BBox
        SelectionColor = [ 0, 153, 255 ] / 255;
        HoverListener
        Interactiondata
        Grid = struct( 'SnapToGrid', 0, 'GridSize', 0.1 );
        Units = 'mm';
        Metal
        OrientationQuiver
        TooltipEvt
        DragInteraction
        NewShapePatch
        NewShapeBox
        CurrentMenu
        ModelInfo
    end

    methods ( Access = protected )
        function performMouseMove( self, varargin )
            self.notifyClickDrag( varargin{ : } );
        end

        function performButtonDown( self, varargin )
            self.notifyClickDrag( varargin{ : } );
        end

        function performButtonUp( self, varargin )
            self.notifyClickDrag( varargin{ : } );
        end
    end
    methods



        function self = Cad2DCanvas( Parent )
            self@cad.Cad2DView( Parent );
            self@matlabshared.application.Canvas(  );
            enableDefaultInteractivity( self.Axes );

            self.MB_ParentFig = getFigure( self );
            initializeKeyBoardBehaviour( self );
            initializeScrollZoom( self );

            self.MB_ParentFig.WindowButtonDownFcn = @self.onButtonDown;





            applyAxesLimits( self, [  - 10, 10 ], [  - 10, 10 ] );
            fig = getFigure( self );
            fig.AutoResizeChildren = 'off';
            fig.ResizeFcn = @( src, evt )updateLimits( self, getAxes( self ) );
        end

        function color = getColor( self )
            color = [ 0, 0, 0 ];
        end

        function selectAll( self )
            selectAllobj( self );
        end
        function left( self )
            if ~isempty( self.SelectedObject )
                selectedIdx = [ self.SelectedObject.Id ];
                selectedType = { self.SelectedObject.Type };
                data.Selection = { selectedType, selectedIdx };
                ax = getAxes( self );
                xlim = ax.XLim;
                xlimdiff = xlim( 2 ) - xlim( 1 );
                data.StartPoint = [ 0, 0, 0 ];
                if self.Grid.SnapToGrid
                    data.EndPoint = [  - 1 * self.Grid.GridSize, 0, 0 ];
                else
                    data.EndPoint = [  - 1 * xlimdiff * 0.01, 0, 0 ];
                end
                self.notify( 'Move', cad.events.ValueChangedEventData( data ) );
            end
        end
        function right( self )
            if ~isempty( self.SelectedObject )
                selectedIdx = [ self.SelectedObject.Id ];
                selectedType = { self.SelectedObject.Type };
                data.Selection = { selectedType, selectedIdx };
                ax = getAxes( self );
                xlim = ax.XLim;
                xlimdiff = xlim( 2 ) - xlim( 1 );
                data.StartPoint = [ 0, 0, 0 ];
                if self.Grid.SnapToGrid
                    data.EndPoint = [ self.Grid.GridSize, 0, 0 ];
                else
                    data.EndPoint = [ xlimdiff * 0.01, 0, 0 ];
                end
                self.notify( 'Move', cad.events.ValueChangedEventData( data ) );
            end
        end
        function up( self )
            if ~isempty( self.SelectedObject )
                selectedIdx = [ self.SelectedObject.Id ];
                selectedType = { self.SelectedObject.Type };
                data.Selection = { selectedType, selectedIdx };
                ax = getAxes( self );
                ylim = ax.YLim;
                ylimdiff = ylim( 2 ) - ylim( 1 );
                data.StartPoint = [ 0, 0, 0 ];
                if self.Grid.SnapToGrid
                    data.EndPoint = [ 0, self.Grid.GridSize, 0 ];
                else
                    data.EndPoint = [ 0, ylimdiff * 0.01, 0 ];
                end
                self.notify( 'Move', cad.events.ValueChangedEventData( data ) );
            end
        end
        function down( self )
            if ~isempty( self.SelectedObject )
                selectedIdx = [ self.SelectedObject.Id ];
                selectedType = { self.SelectedObject.Type };
                data.Selection = { selectedType, selectedIdx };
                ax = getAxes( self );
                ylim = ax.YLim;
                ylimdiff = ylim( 2 ) - ylim( 1 );
                data.StartPoint = [ 0, 0, 0 ];
                if self.Grid.SnapToGrid
                    data.EndPoint = [ 0,  - 1 * self.Grid.GridSize, 0 ];
                else
                    data.EndPoint = [ 0,  - 1 * ylimdiff * 0.01, 0 ];
                end
                self.notify( 'Move', cad.events.ValueChangedEventData( data ) );
            end
        end

        function escape( self )
            exitInteraction( self );
        end
        function applyAxesLimits( this, hLim, vLim )



            hAxes = this.Axes;
            hAxes.CameraPositionMode = 'auto';
            hAxes.CameraTargetMode = 'auto';

            if vLim( 1 ) > vLim( 2 ) || hLim( 1 ) > hLim( 2 ) || vLim( 1 ) == vLim( 2 ) ||  ...
                    hLim( 1 ) == hLim( 2 )
                return ;
            end
            if abs( vLim( 1 ) - vLim( 2 ) ) < 10 * eps( vLim( 1 ) ) || abs( hLim( 1 ) - hLim( 2 ) ) < 10 * eps( hLim( 1 ) )
                return ;
            end
            center( 1 ) = mean( hLim );
            center( 2 ) = mean( vLim );


            pos = getpixelposition( this.Axes );

            hUnitsPerPixel = diff( hLim ) / pos( 3 );
            vUnitsPerPixel = diff( vLim ) / pos( 4 );

            unitsPerPixel = hUnitsPerPixel;
            if vUnitsPerPixel > hUnitsPerPixel
                unitsPerPixel = vUnitsPerPixel;
            end

            setCenterAndUnitsPerPixel( this, center, unitsPerPixel );
        end





















































        function set.SelectedObject( self, val )
            self.SelectedObject = val;

        end

        function initializeTooltipHandler( this )

            self.HoverListener = addlistener( this, 'Hover', @this.setCursorText );
        end

        function setTooltipString( self, str )
            if isempty( self.hTooltip ) || ~isvalid( self.hTooltip )
                self.hTooltip = annotation( self.Figure, 'textbox', 'FitBoxToText',  ...
                    'on', 'EdgeColor', [ 0.8, 0.8, 0.8 ], 'BackgroundColor',  ...
                    [ 0.98, 0.98, 0.98 ], 'tag', 'Tooltip', 'HitTest', "off", 'Interpreter', 'none', 'PickableParts', 'none' );
                self.hTooltip.Units = 'pixels';
            end
            if isempty( str )
                self.hTooltip.Visible = 'off';
            else
                self.hTooltip.String = str;
                self.hTooltip.Visible = 'on';
                try
                    self.hTooltip.Position( 1:2 ) = self.TooltipEvt.Point( 1:2 ) - [  - 5, 5 + self.hTooltip.Position( 4 ) ];
                catch
                end
            end

        end
        function setCursorText( this, varargin )

            if isempty( varargin )
                [ newString, ~ ] = getCursorText( this );
            else
                newString = varargin{ 1 };
            end
            setTooltipString( this, newString )
        end
        function [ tooltip, cp ] = getCursorText( this )
            cp = getCurrentPoint( this );
            tooltip = num2str( cp( 1 ) ) + "," + num2str( cp( 2 ) );
        end

        function [ tooltip, cp ] = genCursorTextFromPos( this, x, y )
            cp = [ x, y ];
            tooltip = num2str( cp( 1 ) ) + "," + num2str( cp( 2 ) );
        end

        function tooltip = genCursorTextFromArgs( self, objVal )
            args = objVal.Info.Args;
            if strcmpi( objVal.Info.Type, 'Rectangle' )
                tooltip = [ 'Name: ', objVal.Info.Name, newline,  ...
                    'Length: ', num2str( args.Length ), newline,  ...
                    'Width: ', num2str( args.Width ), newline,  ...
                    'Center: ', getCenterTooltip( self, args.Center ), newline,  ...
                    'Angle: ', num2str( args.Angle ) ];
            elseif strcmpi( objVal.Info.Type, 'Circle' )
                tooltip = [ 'Name: ', objVal.Info.Name, newline,  ...
                    'Radius: ', num2str( args.Radius ), newline,  ...
                    'Center: ', getCenterTooltip( self, args.Center ) ];
            elseif strcmpi( objVal.Info.Type, 'Ellipse' )
                tooltip = [ 'Name: ', objVal.Info.Name, newline,  ...
                    'MajorAxis: ', num2str( args.MajorAxis ), newline,  ...
                    'MinorAxis: ', num2str( args.MinorAxis ), newline,  ...
                    'Center: ', getCenterTooltip( self, args.Center ), newline,  ...
                    'Angle: ', num2str( args.Angle ) ];
            elseif strcmpi( objVal.Info.Type, 'Polygon' )
                tooltip = [ 'Name: ', objVal.Info.Name ];
            elseif any( strcmpi( objVal.Info.Type, { 'Feed', 'Via', 'Load' } ) )
                tooltip = [ 'Name: ', objVal.Info.Name, newline,  ...
                    'Start Layer: ', args.StartLayer.Name, newline,  ...
                    'Stop Layer: ', args.StopLayer.Name, newline,  ...
                    'Center: ', getCenterTooltip( self, args.Center ) ];
                if strcmpi( objVal.Info.Type, 'Feed' )
                    tooltip = [ tooltip, newline ];
                    tooltip = [ tooltip, 'FeedDiameter: ', num2str( args.Diameter ), newline ];
                    tooltip = [ tooltip, 'FeedVoltage: ', num2str( args.FeedVoltage ), newline,  ...
                        'FeedPhase: ', num2str( args.FeedPhase ) ];
                elseif strcmpi( objVal.Info.Type, 'Load' )
                    tooltip = [ tooltip, newline ];
                    tooltip = [ tooltip, 'Impedance: ', getCenterTooltip( self, args.Impedance ), newline,  ...
                        'Frequency: ', getCenterTooltip( self, args.Frequency ) ];
                elseif strcmpi( objVal.Info.Type, 'Via' )
                    tooltip = [ tooltip, newline ];
                    tooltip = [ tooltip, 'ViaDiameter: ', num2str( args.Diameter ) ];
                end
            elseif strcmpi( objVal.Info.Type, 'Layer' )

                if objVal.Info.Id ~= 1
                    tooltip = [ 'Name: ', objVal.Info.Name, newline,  ...
                        'Type: ', args.Type, newline ];
                    if strcmpi( args.Type, 'Metal' )
                        tooltip = [ tooltip,  ...
                            'LayerHeight: ', num2str( objVal.Info.ZVal ) ];
                    else
                        tooltip = [ tooltip,  ...
                            'Dielectric Type: ', args.DielectricType, newline ...
                            , 'EpsilonR: ', num2str( args.EpsilonR ), newline ...
                            , 'LossTangent: ', num2str( args.LossTangent ), newline ...
                            , 'Thickness: ', num2str( args.Thickness ) ];
                    end
                else
                    tooltip = objVal.Info.Name;
                end
            end
        end

        function centerTooltip = getCenterTooltip( self, centerval )
            if ischar( centerval ) || isstring( centerval )
                centerTooltip = num2str( centerval );
            else
                centerTooltip = mat2str( centerval );
            end
        end

        function [ cp, xUnitsPerPixel, yUnitsPerPixel, N ] = getCurrentPoint( this )
            xUnitsPerPixel = 0;
            yUnitsPerPixel = 0;
            N = 0;


            ax = this.Axes;
            try
                cp = this.TooltipEvt.IntersectionPoint( 1:2 );
            catch
                cp = getCurrentPoint@matlabshared.application.Canvas( this );
            end
        end

        function drawShape( self, Type )
            enterInteraction( self, [ 'Draw', Type ] );
        end
        function addShape( self, Type, varargin )
            if isempty( varargin )
                BBox = getBBoxFromAxLim( self );
            else
                BBox = varargin{ 1 };
            end









            for i = 1:numel( BBox )
                BBox( i ) = BBox( i ) - mod( abs( BBox( i ) ), self.Grid.GridSize ) *  ...
                    BBox( i ) / abs( BBox( i ) );
            end

            if strcmpi( Type, 'Polygon' )
                self.notify( 'AddShape', cad.events.AddEventData( 'Shape', Type, BBox, varargin{ 1 } ) );
            else
                self.notify( 'AddShape', cad.events.AddEventData( 'Shape', Type, BBox ) );
            end
        end

        function addOperation( self, Type )
            if ~isempty( self.SelectedObject )
                id = [ self.SelectedObject.Id ];
            else
                return ;
            end

            if ~all( strcmpi( { self.SelectedObject.Type }, 'Shape' ) )
                return ;
            end
            if numel( id ) < 2
                errordlg( getString( message( "antenna:pcbantennadesigner:RequireTwoShapes" ) ), 'Error' );
                return ;
            end
            if numel( id ) ~= 2 && any( strcmpi( Type, { 'Xor', 'subtract', 'intersect' } ) )
                errordlg( getString( mesage( "antenna:pcbantennadesigner:RequireTwoShapes", Type ) ), 'Error' );
                return ;
            end

            if strcmpi( Type, 'Subtract' )
                try
                    performSubtract( self, self.SelectedObject( 1 ).Info.ShapeObj,  ...
                        self.SelectedObject( 2 ).Info.ShapeObj );
                catch
                    errordlg( getString( message( 'antenna:pcbantennadesigner:CannotPerformSubtract',  ...
                        self.SelectedObject( 2 ).Info.Name, self.SelectedObject( 1 ).Info.Name ) ),  ...
                        'Error' );
                    return ;
                end
            end

            if strcmpi( Type, 'Intersect' )
                try
                    performIntersect( self, self.SelectedObject( 1 ).Info.ShapeObj,  ...
                        self.SelectedObject( 2 ).Info.ShapeObj );
                catch
                    errordlg( getString( message( 'antenna:pcbantennadesigner:CannotPerformIntersect',  ...
                        self.SelectedObject( 2 ).Info.Name, self.SelectedObject( 1 ).Info.Name ) ),  ...
                        'Error' );
                    return ;
                end
            end

            self.notify( 'AddOperation', cad.events.AddEventData( 'Operation', Type, id ) );
        end

        function op = performIntersect( self, ip1, ip2 )
            op = ip1 & ip2;
        end

        function op = performSubtract( self, ip1, ip2 )
            op = ( ip1 - ip2 );
        end

        function moveShape( self, Type, varargin )
            self.notify( 'MoveShape', cad.events.MoveEventData( 'Shape', Type, BBox ) );
        end

        function modelChanged( self, evt )

            if ~isempty( evt.ModelInfo )
                self.ModelInfo = evt.ModelInfo;
            end
            exitInteraction( self, evt );
            if strcmpi( evt.EventType, 'ShapeAdded' ) || strcmpi( evt.EventType, 'ShapeChanged' )
                addShapeView( self, evt.Data );
            elseif strcmpi( evt.EventType, 'ShapeDeleted' )
                deleteShapeView( self, evt.Data );
            end
            drawOrientation( self );
        end

        function drawOrientation( self )
            return ;
            ax = self.Axes;
            if ~isempty( self.OrientationQuiver )
                self.OrientationQuiver.delete;
            end

            dist = [ diff( ax.XLim' ), diff( ax.YLim' ), diff( ax.ZLim )' ];
            centerpt = [ ax.XLim( 1 ), ax.YLim( 1 ), 0 ] + [ dist( 1:2 ), 0 ] .* 0.02;
            dist( 1:2 ) = min( dist( 1:2 ) );
            h = hggroup( ax );
            hold( ax, 'on' );
            qx = quiver3( ax, centerpt( 1 ), centerpt( 2 ), 0, dist( 1 ) * 0.1, 0, 0, 'Color', 'r', 'MaxHeadSize', 1 );
            qy = quiver3( ax, centerpt( 1 ), centerpt( 2 ), 0, 0, dist( 2 ) * 0.1, 0, 'Color', 'g', 'MaxHeadSize', 1 );
            hold( ax, 'off' );
            qx.Parent = h;
            qy.Parent = h;
            self.OrientationQuiver = h;
            h.Parent = ax;
            set( h.Children, 'LineWidth', 1 );
            pt = centerpt + [ dist( 1 ) * 0.1, 0, dist( 3 ) * 0.1 ];
            xtext = text( ax, pt( 1 ), pt( 2 ), 0, 'X', 'FontWeight', 'bold' );
            pt = centerpt + [ 0, dist( 2 ) * 0.1, dist( 3 ) * 0.1 ];
            ytext = text( ax, pt( 1 ), pt( 2 ), 0, 'Y', 'FontWeight', 'bold' );
            xtext.Parent = h;
            ytext.Parent = h;
            h.Parent = ax;
            set( h.Children, 'PickableParts', 'none' );
        end

        function ShapeViewObj = addShapeView( self, info )
            ShapeViewObj = [  ];
            if ( ~isempty( info.ParentId ) && strcmpi( info.ParentType, 'Layer' ) ) || strcmpi( info.Type, 'Layer' )
                if ~isempty( self.ObjectStack )
                    idx = [ self.ObjectStack.Id ] == info.Id;
                    if any( idx )
                        pobj = self.ObjectStack( idx );
                        pobj.update( info );
                        ShapeViewObj = pobj;
                    else
                        ShapeViewObj = cad.ShapeView( self, info );
                        self.ObjectStack = [ ShapeViewObj, self.ObjectStack ];
                    end
                else
                    ShapeViewObj = cad.ShapeView( self, info );
                    self.ObjectStack = [ ShapeViewObj, self.ObjectStack ];
                end

            else
                if ~isempty( self.ObjectStack )
                    idx = [ self.ObjectStack.Id ] == info.Id;
                    if any( idx )
                        pobj = self.ObjectStack( idx );
                        self.ObjectStack( idx ) = [  ];
                        pobj.delete;
                    end
                end
            end

            if ~isempty( self.HoverObject ) && isvalid( self.HoverObject )

                unhover( self.HoverObject );
            end
            self.HoverObject = [  ];
            if numel( self.SelectedObject ) > 1
                for i = 1:numel( self.SelectedObject )
                    if isvalid( self.SelectedObject( i ) )
                        unselect( self.SelectedObject( i ) )
                    end
                end
                self.SelectedObject = [  ];
            else
                for i = 1:numel( self.SelectedObject )
                    if isvalid( self.SelectedObject( i ) )
                        if self.SelectedObject.Id ~= info.Id
                            unselect( self.SelectedObject( i ) )
                            self.SelectedObject = [  ];
                        end
                    else
                        self.SelectedObject = [  ];
                    end
                end
            end
        end


        function updateLimits( self, ax )
            arguments
                self
                ax = self.Axes;
            end
            updateLimits@matlabshared.application.FillAxes( self, ax );
            drawOrientation( self );
            self.InstructionalText.Position = [ ax.XLim( 1 ) + 0.1 * ( ax.XLim( 2 ) - ax.XLim( 1 ) ), ( ax.YLim( 2 ) + ax.YLim( 1 ) ) / 2, 0 ];
        end

        function deleteShapeView( self, info )
            if ~isempty( self.ObjectStack )
                idx = [ self.ObjectStack.Id ] == info.Id;
                if any( idx )
                    pobj = self.ObjectStack( idx );
                    self.ObjectStack( idx ) = [  ];
                    pobj.delete;
                end
            end
            if ~isempty( self.HoverObject ) && isvalid( self.HoverObject )
                unhover( self.HoverObject );
            end
            self.HoverObject = [  ];
            for i = 1:numel( self.SelectedObject )
                if isvalid( self.SelectedObject( i ) )
                    unselect( self.SelectedObject( i ) )
                end
            end
            self.SelectedObject = [  ];

        end
        function drawPolygon( self, src, evt )
            enterInteraction( self, 'DrawingPolygon', evt );
        end



        function hover( self, evt )

            tmp.IntersectionPoint = evt.IntersectionPoint;

            tmp.HitObject = evt.HitObject;
            tmp.Point = evt.Point;
            evt = tmp;

            if self.Grid.SnapToGrid
                evt.IntersectionPoint( 1 ) = movePointToGrid( self, evt.IntersectionPoint( 1 ) );
                evt.IntersectionPoint( 2 ) = movePointToGrid( self, evt.IntersectionPoint( 2 ) );
                self.TooltipEvt = evt;
            else
                evt.IntersectionPoint( 1 ) = round( evt.IntersectionPoint( 1 ), 3 );
                evt.IntersectionPoint( 2 ) = round( evt.IntersectionPoint( 2 ), 3 );
                self.TooltipEvt = evt;
            end
            if ~isempty( self.InteractionMode )
                updateInteraction( self, 'hover', evt );
                return ;
            end















            hitObj = evt.HitObject;



            if ~isempty( self.HoverObject )
                unhover( self.HoverObject );
                self.HoverObject = [  ];
            end
            if ~isempty( hitObj.Tag ) && any( strcmpi( hitObj.Tag, { 'Shape', 'feed', 'Via', 'Load' } ) )
                objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                if ~isempty( objVal )
                    hover( objVal );
                end
                if isfield( hitObj.UserData, 'MarkerType' )
                    [ newString, ~ ] = genCursorTextFromPos( self, hitObj.XData, hitObj.YData );
                    newString = [ 'Position: ', newString ];
                else
                    newString = genCursorTextFromArgs( self, objVal );
                end
                setCursorText( self, newString );
                self.HoverObject = objVal;
            elseif strcmpi( hitObj.Type, 'axes' )
                setCursorText( self, '' );
            elseif ~isempty( hitObj.Tag ) && strcmpi( hitObj.Tag, 'Rotate' )
                objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                newString = [ 'Angle: ', num2str( objVal.Info.Args.Angle ) ];
                self.setCursorText( newString );
            elseif ~isempty( hitObj.Tag ) && strcmpi( hitObj.Tag, 'Layer' )
                objVal = self.findOverlayObj( hitObj.UserData.Id, hitObj.UserData.Type );
                newString = genCursorTextFromArgs( self, objVal );
                setCursorText( self, newString );

            else
                if ~isempty( self.hTooltip )
                    self.hTooltip.delete;
                end
                self.hTooltip = [  ];
            end

            if ~isempty( self.hTooltip )
                self.hTooltip.HitTest = 'on';
                self.hTooltip.PickableParts = 'none';
            end
        end

        function rightClick( self, evt, varargin )
            bypassSelectMultiple = 0;
            if ~isempty( varargin )
                bypassSelectMultiple = varargin{ 1 };
            end

            if self.KB_SelectMultiple && ~bypassSelectMultiple
                leftClick( self, evt, 1 );
                return ;
            end
        end

        function groupAxesChildren( self )
            ax = getAxes( self );
            patchObj = findobj( ax, 'type', 'patch' );
            childobj = ax.Children;
            if ~isempty( patchObj )
                data = { patchObj.UserData };
                emptyidx = cell2mat( cellfun( @( x )isempty( x ), data, 'UniformOutput', false ) );
                data = data( ~emptyidx );
                ids = ( cell2mat( cellfun( @( x )x.Id, data, 'UniformOutput', false ) ) );
                childrenStack = [  ];

                childdata = cell( 1, numel( childobj ) );
                for i = 1:numel( childobj )
                    childdata{ i } = childobj( i ).UserData;
                end
                emptyidx = cell2mat( cellfun( @( x )isempty( x ), childdata, 'UniformOutput', false ) );
                childdata = childdata( ~emptyidx );
                idsOfChild = cell2mat( cellfun( @( x )x.Id, childdata, 'UniformOutput', false ) );
                notemptyuserDataChildobj = childobj( ~emptyidx );
                prevsortid = [  ];
                for i = 1:numel( ids )
                    if ~isempty( prevsortid ) && prevsortid == ids( i )
                        continue ;
                    end
                    childrenStack = [ childrenStack;notemptyuserDataChildobj( idsOfChild == ids( i ) ) ];
                    prevsortid = ids( i );
                end
                childrenStack = [ childrenStack;childobj( emptyidx );findobj( ax, 'type', 'polygon' ) ];
                ax.Children = childrenStack;
                ax.Children = [ findobj( ax.Children, '-not', 'tag', 'Layer' );findobj( ax.Children, 'tag', 'Layer' ) ];
            end
        end

        function fitToView( self )




            patchObj = findall( getAxes( self ), 'type', 'patch' );
            if isempty( patchObj )
                actorVertices = zeros( 0, 3 );
            else
                actorVertices = vertcat( patchObj.Vertices );
            end
            lines = findall( getAxes( self ), 'type', 'line' );
            if isempty( lines )
                linePoints = zeros( 0, 3 );
            else
                linePoints = [ horzcat( lines.XData )',  ...
                    horzcat( lines.YData )' ];
                linePoints = [ linePoints, zeros( size( linePoints, 1 ), 1 ) ];
            end
            verts = vertcat( actorVertices, linePoints );

            if isempty( verts )
                self.applyDefaultAxesLimits(  );
            else

                [ xMin, xMax ] = bounds( verts( :, 1 ) );
                [ yMin, yMax ] = bounds( verts( :, 2 ) );

                [ minSpan, maxSpan ] = self.getAxesSpan(  );
                minHalf = minSpan / 2;
                maxHalf = maxSpan / 2;


                bufferPercent = 5;
                f = 1 + bufferPercent / 100;


                half = f * ( xMax - xMin ) / 2;
                half = min( max( half, minHalf ), maxHalf );
                xLim = [  - half, half ] + ( xMin + xMax ) / 2;

                half = f * ( yMax - yMin ) / 2;
                half = min( max( half, minHalf ), maxHalf );
                yLim = [  - half, half ] + ( yMin + yMax ) / 2;
                self.applyAxesLimits( xLim, yLim );
            end
        end

        function createContextMenu( self, src, evt, varargin )
            cm = src;
            self.CurrentMenu = cm;
            if ~isempty( cm.Children )
                cm.Children.delete;
                cm.Children = [  ];
            end
            if self.KB_SelectMultiple || ~isempty( self.InteractionMode )
                return ;
            end
            m0 = uimenu( cm, 'text', 'Fit to View', 'MenuSelectedFcn', @( src, evt )fitToView( self ) );
            m1 = uimenu( cm, 'text', 'Undo', 'MenuSelectedFcn', @( src, evt )undo( self ), 'Separator', 'on' );
            m2 = uimenu( cm, 'text', 'Redo', 'MenuSelectedFcn', @( src, evt )redo( self ) );
            m3 = uimenu( cm, 'text', 'Cut', 'Separator', 'on', 'MenuSelectedFcn', @( src, evt )cut( self ) );
            m4 = uimenu( cm, 'text', 'Copy', 'MenuSelectedFcn', @( src, evt )copy( self ) );
            m5 = uimenu( cm, 'text', 'Paste', 'MenuSelectedFcn', @( src, evt )paste( self ) );
            m6 = uimenu( cm, 'text', 'Delete' );
            m7 = uimenu( cm, 'text', 'Add', 'MenuSelectedFcn', @( src, evt ) ...
                self.addOperation( 'Add' ),  ...
                'Separator', 'on' );
            m8 = uimenu( cm, 'text', 'Subtract', 'MenuSelectedFcn', @( src, evt ) ...
                self.addOperation( 'Subtract' ) );
            m9 = uimenu( cm, 'text', 'Intersect', 'MenuSelectedFcn', @( src, evt ) ...
                self.addOperation( 'Intersect' ) );
            m10 = uimenu( cm, 'text', 'Xor', 'MenuSelectedFcn', @( src, evt ) ...
                self.addOperation( 'Xor' ) );
            m11 = uimenu( cm, 'text', 'Bring to Front', 'Separator', 'on' );
            m12 = uimenu( cm, 'text', 'Send to Back' );
            if ~isempty( varargin )
                m11.MenuSelectedFcn = @( src, evt )self.bringForward( src, evt, varargin{ 1 } );
                m12.MenuSelectedFcn = @( src, evt )self.sendToBack( src, evt, varargin{ 1 } );
                m6.MenuSelectedFcn = @( src, evt )self.deleteShapeObject( src, evt, varargin{ 1 } );
            else
                m11.Enable = 'off';
                m12.Enable = 'off';
                m6.Enable = 'off';
            end
            if ~( numel( self.SelectedObject ) >= 1 )
                m3.Enable = 'off';
                m4.Enable = 'off';
                m5.Enable = 'off';
            end
            if ~( numel( self.SelectedObject ) >= 2 ) || ~( all( strcmpi( { self.SelectedObject.Type }, 'Shape' ) ) )
                m7.Enable = 'off';
            end

            if ~( numel( self.SelectedObject ) == 2 ) || ~( all( strcmpi( { self.SelectedObject.Type }, 'Shape' ) ) )
                m8.Enable = 'off';
                m9.Enable = 'off';
                m10.Enable = 'off';
            end
            modelInfo = self.ModelInfo;

            if ~isempty( modelInfo )
                if modelInfo.ActionsStatus( 1 )
                    m3.Enable = 'on';
                else
                    m3.Enable = 'off';
                end

                if modelInfo.ActionsStatus( 2 )
                    m4.Enable = 'on';
                else
                    m4.Enable = 'off';
                end

                if modelInfo.ActionsStatus( 3 )
                    m5.Enable = 'on';
                else
                    m5.Enable = 'off';
                end

                if modelInfo.ActionsStatus( 4 )
                    m6.Enable = 'on';
                else
                    m6.Enable = 'off';
                end

                if modelInfo.ActionsSize > 0
                    m1.Enable = 'on';
                else
                    m1.Enable = 'off';
                end

                if modelInfo.RedoStackSize > 0
                    m2.Enable = 'on';
                else
                    m2.Enable = 'off';
                end
            end

            pause( 0.01 )
            open( cm, evt.Source.Parent.CurrentPoint );
        end
        function createContextMenuForShape( self, cm, id )
            cm = createOperationContextMenu( self, cm );
            if ~isempty( cm.Children )
                return ;
            end
            m1 = uimenu( cm, 'text', 'Bring To Front', 'MenuSelectedFcn', @( src, evt )self.bringForward( src, evt, id ) );
            m2 = uimenu( cm, 'text', 'Send To Back', 'MenuSelectedFcn', @( src, evt )self.sendToBack( src, evt, id ) );
            m3 = uimenu( cm, 'text', 'Delete Shape', 'MenuSelectedFcn', @( src, evt )self.deleteShapeObject( src, evt, id ) );
        end

        function deleteShapeObject( self, src, evt, id )
            self.notify( 'DeleteShape', cad.events.DeleteEventData( 'Shape', id, 1 ) );
        end

        function bringForward( self, src, evt, id )
            ax = getAxes( self );
            childobj = ax.Children;
            childdata = cell( 1, numel( childobj ) );
            for i = 1:numel( childobj )
                childdata{ i } = childobj( i ).UserData;
            end
            emptyidx = cell2mat( cellfun( @( x )isempty( x ), childdata, 'UniformOutput', false ) );
            childdata = childdata( ~emptyidx );
            idsOfChild = cell2mat( cellfun( @( x )x.Id, childdata, 'UniformOutput', false ) );
            notemptyuserDataChildobj = childobj( ~emptyidx );

            objectsval = idsOfChild == id;
            childrenStack = [ notemptyuserDataChildobj( objectsval );notemptyuserDataChildobj( ~objectsval ) ];
            ax.Children = [ childrenStack;childobj( emptyidx ) ];
            ax.Children = [ findobj( ax.Children, '-not', 'tag', 'Layer' );findobj( ax.Children, 'tag', 'Layer' ) ];
        end

        function sendToBack( self, src, evt, id )
            ax = getAxes( self );

            childobj = ax.Children;
            childdata = cell( 1, numel( childobj ) );
            for i = 1:numel( childobj )
                childdata{ i } = childobj( i ).UserData;
            end
            emptyidx = cell2mat( cellfun( @( x )isempty( x ), childdata, 'UniformOutput', false ) );
            childdata = childdata( ~emptyidx );
            idsOfChild = cell2mat( cellfun( @( x )x.Id, childdata, 'UniformOutput', false ) );
            notemptyuserDataChildobj = childobj( ~emptyidx );

            objectsval = idsOfChild == id;
            childrenStack = [ notemptyuserDataChildobj( ~objectsval );notemptyuserDataChildobj( objectsval ); ];
            ax.Children = [ childrenStack;childobj( emptyidx ) ];
            ax.Children = [ findobj( ax.Children, '-not', 'tag', 'Layer' );findobj( ax.Children, 'tag', 'Layer' ) ];
        end
        function createContextMenuForCanvas( self, cm )
            cm = createOperationContextMenu( self, cm );
            if ~isempty( cm.Children )
                return ;
            end
            m1 = uimenu( cm, 'text', 'Add Shape' );
            sbm1 = uimenu( m1, 'text', 'Rectangle', 'MenuSelectedFcn', @( src, evt )self.addShape( 'Rectangle' ) );
            sbm2 = uimenu( m1, 'text', 'Circle', 'MenuSelectedFcn', @( src, evt )self.addShape( 'Circle' ) );
            sbm2 = uimenu( m1, 'text', 'Polygon', 'MenuSelectedFcn', @( src, evt )self.drawPolygon( src, evt ) );
            m2 = uimenu( cm, 'text', 'Add Layer', 'MenuSelectedFcn', @( src, evt )self.addLayer( src, evt ) );
        end

        function cm = createOperationContextMenu( self, cm )

            if numel( self.SelectedObject ) >= 2
                m1 = uimenu( cm, 'text', 'Add', 'MenuSelectedFcn', @( src, evt ) ...
                    self.addOperation( 'Add', [ self.SelectedObject.Id ] ) );
                if numel( self.SelectedObject ) == 2
                    m2 = uimenu( cm, 'text', 'Subtract', 'MenuSelectedFcn', @( src, evt ) ...
                        self.addOperation( 'Subtract', [ self.SelectedObject.Id ] ) );

                    m3 = uimenu( cm, 'text', 'Intersect', 'MenuSelectedFcn', @( src, evt ) ...
                        self.addOperation( 'Intersect', [ self.SelectedObject.Id ] ) );

                    m4 = uimenu( cm, 'text', 'Xor', 'MenuSelectedFcn', @( src, evt ) ...
                        self.addOperation( 'Xor', [ self.SelectedObject.Id ] ) );
                end
            end

        end
        function leftClick( self, evt, varargin )
            bypassSelectMultiple = 0;
            if ~isempty( varargin )
                bypassSelectMultiple = varargin{ 1 };
            end

            if self.KB_SelectMultiple && ~bypassSelectMultiple
                rightClick( self, evt, 1 );
                return ;
            end
            tmp.IntersectionPoint = evt.IntersectionPoint;

            tmp.HitObject = evt.HitObject;

            evt = tmp;
            if self.Grid.SnapToGrid
                evt.IntersectionPoint( 1 ) = movePointToGrid( self, evt.IntersectionPoint( 1 ) );
                evt.IntersectionPoint( 2 ) = movePointToGrid( self, evt.IntersectionPoint( 2 ) );
                self.TooltipEvt = evt;
            else
                self.TooltipEvt = evt;
            end
            if strcmpi( self.InteractionMode, 'DrawingPolygon' )
                if ~any( isnan( evt.IntersectionPoint ) )
                    self.PolygonDraw.Points = [ self.PolygonDraw.Points;evt.IntersectionPoint ];
                    markerObj = line( 'Parent', self.Axes,  ...
                        'XData', evt.IntersectionPoint( 1 ), 'YData', evt.IntersectionPoint( 2 ),  ...
                        'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k', 'MarkerSize', 10,  ...
                        'Marker', 'o' );
                    self.PolygonDraw.Marker = [ self.PolygonDraw.Marker;markerObj ];
                    markerObjects = self.PolygonDraw.Marker( end  - 1:end  );
                    xval = markerObjects.XData;
                    yval = markerObjects.YData;
                    lineObj = line( 'Parent', self.Axes, 'LineStyle',  ...
                        '--', 'Color', 'k', 'LineWidth', 2, 'XData', xval, 'YData', yval );
                    self.PolygonDraw.Line = [ self.PolygonDraw.Line;lineObj ];
                end
                return ;
            end
            if ~isempty( evt.HitObject ) && any( strcmpi( evt.HitObject.Tag, { 'Shape', 'Feed', 'Via', 'Load' } ) )
                if ~isempty( evt.HitObject.Tag )
                    hitObj = evt.HitObject;
                    objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                    shapeClicked( self, objVal );
                    groupAxesChildren( self );
                end
            else
                if ~isempty( self.SelectedObject )
                    for i = 1:numel( self.SelectedObject )
                        unselect( self.SelectedObject( i ) );
                    end
                    self.SelectedObject = [  ];
                end
            end

            if ~isempty( self.SelectedObject )
                data = { { self.SelectedObject.Type }, [ self.SelectedObject.Id ] };
            else
                data = [  ];
            end
            self.notify( 'Selected', cad.events.SelectionEventData( data, 'Canvas' ) );
        end

        function shapeClicked( self, objVal )
            if objVal.Selected
                unselectShape( self, objVal )
            else
                selectShape( self, objVal )
            end
        end
        function selectShape( self, objVal, varargin )
            if ~isempty( varargin )
                append = 1;
            else
                append = 0;
            end
            if self.KB_SelectMultiple
                addShapeObjtoSelection( self, objVal, 1 );
            else
                addShapeObjtoSelection( self, objVal, append );
            end

        end

        function unselectShape( self, objVal )
            if self.KB_SelectMultiple
                removeShapeObjfromSelection( self, objVal );
            else
                removeShapeObjfromSelection( self, objVal, 1 );
            end
        end

        function shapeObj = findSelectedShapeObj( self, objValId )
            if isempty( self.SelectedObject )
                shapeObj = [  ];
                return ;
            end
            ids = [ self.SelectedObject.Id ];
            shapeObj = [  ];
            if any( ids == objValId )
                shapeObj = self.SelectedObject( ids == objValId );
            end
        end

        function addShapeObjtoSelection( self, objVal, varargin )
            appendFlag = 0;
            if ~isempty( varargin )
                appendFlag = varargin{ 1 };
            end
            shapeObj = findSelectedShapeObj( self, objVal.Id );
            if isempty( shapeObj )
                select( objVal );
                if appendFlag
                    self.SelectedObject = [ self.SelectedObject, objVal ];
                else
                    self.unselectAllSelection(  );
                    self.SelectedObject = objVal;
                end
            end
        end

        function removeShapeObjfromSelection( self, objVal, varargin )
            removeAll = 0;
            if ~isempty( varargin )
                removeAll = varargin{ 1 };
            end
            shapeObj = findSelectedShapeObj( self, objVal.Id );
            if ~isempty( shapeObj )
                unselect( shapeObj )
                if ~removeAll && ~isempty( self.SelectedObject )

                    idx = [ self.SelectedObject.Id ] == objVal.Id;
                    self.SelectedObject( idx ) = [  ];
                end
            end

            if removeAll
                unselectAllSelection( self );
            end
        end

        function unselectAllSelection( self )
            for i = 1:numel( self.SelectedObject )
                unselect( self.SelectedObject( i ) );
            end
            self.SelectedObject = [  ];
        end

        function selectAllobj( self )
            for i = 1:numel( self.ObjectStack )
                selectShape( self, self.ObjectStack( i ), 1 );
            end
            if ~isempty( self.SelectedObject )
                type = {  };
                id = [  ];
                for i = 1:numel( self.SelectedObject )
                    type = [ type;{ self.SelectedObject( i ).Type } ];
                    id = [ id;[ self.SelectedObject( i ).Id ] ];
                end
                data = { type, id };
                self.notify( 'Selected', cad.events.SelectionEventData( data, 'Canvas' ) );
            else
                data = [  ];
            end

        end

        function doubleClick( self, evt )
            interactionData = [  ];
            if ~isempty( self.InteractionMode )
                interactionData = exitInteraction( self, evt );
            end
            if ~isempty( interactionData ) && strcmpi( interactionData.Mode, 'DrawingPolygon' )
                if isempty( interactionData.Points )
                    errordlg( interactionData.ErrorMsg, 'Error' );
                else
                    Points = interactionData.Points;
                    self.addShape( 'Polygon', [ Points( :, 1:2 ), zeros( size( Points, 1 ), 1 ) ] );
                end
            end
        end


        function dragStarted( self, evt1, evt2 )
            if any( isnan( evt1.IntersectionPoint ) ) || any( isnan( evt2.IntersectionPoint ) )
                return ;
            end
            tmp.IntersectionPoint = evt2.IntersectionPoint;
            tmp.HitObject = evt2.HitObject;
            tmp.Point = evt2.Point;

            evt2 = tmp;

            tmp.IntersectionPoint = evt1.IntersectionPoint;

            tmp.HitObject = evt1.HitObject;
            tmp.Point = evt1.Point;

            evt1 = tmp;
            if self.Grid.SnapToGrid
                evt2.IntersectionPoint( 1 ) = movePointToGrid( self, evt2.IntersectionPoint( 1 ) );
                evt2.IntersectionPoint( 2 ) = movePointToGrid( self, evt2.IntersectionPoint( 2 ) );
                evt1.IntersectionPoint( 1 ) = movePointToGrid( self, evt1.IntersectionPoint( 1 ) );
                evt1.IntersectionPoint( 2 ) = movePointToGrid( self, evt1.IntersectionPoint( 2 ) );
            else
                evt2.IntersectionPoint( 1 ) = round( evt2.IntersectionPoint( 1 ), 3 );
                evt2.IntersectionPoint( 2 ) = round( evt2.IntersectionPoint( 2 ), 3 );
                evt1.IntersectionPoint( 1 ) = round( evt1.IntersectionPoint( 1 ), 3 );
                evt1.IntersectionPoint( 2 ) = round( evt1.IntersectionPoint( 2 ), 3 );

            end

            if any( isnan( evt2.IntersectionPoint ) )
                return ;
            end
            if ~isempty( self.InteractionMode )
                enterInteraction( self, self.InteractionMode, evt1, evt2 );
                return ;
            end

            if strcmpi( evt1.HitObject.Type, 'axes' )
                p = pan( getFigure( self ) );
                if strcmpi( p.Enable, 'off' )
                    enterInteraction( self, 'SelectionMode', evt1, evt2 );
                else
                    exitInteraction( self, evt1, evt2 );
                end
            elseif any( strcmpi( evt1.HitObject.Type, { 'Shape', 'Feed', 'Via', 'Load' } ) )
                hitObj = evt1.HitObject;
                objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                if ~objVal.Info.EnableMove
                    return ;
                end
                if ~isempty( self.SelectedObject )
                    selectedIdx = [ self.SelectedObject.Id ];
                    if any( selectedIdx == objVal.Id )
                        for i = 1:numel( self.SelectedObject )
                            drag( self.SelectedObject( i ), evt1, evt2 );
                        end
                    else
                        drag( objVal, evt1, evt2 );
                    end
                else
                    drag( objVal, evt1, evt2 );
                end
            elseif any( strcmpi( evt1.HitObject.Tag, { 'Resize', 'Rotate' } ) )
                if ~isempty( evt1.HitObject.UserData )

                    hitObj = evt1.HitObject;
                    objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                    if ~objVal.Info.EnableResize && strcmpi( evt1.HitObject.Tag, 'Resize' )
                        return ;
                    end
                    if isfield( objVal.Info, 'EnableRotate' ) && ~objVal.Info.EnableRotate && strcmpi( evt1.HitObject.Tag, 'Rotate' )
                        return ;
                    end
                    self.RotateStartData = objVal.ResizeView.RotAngle;
                    self.DragStartData = getBounds( objVal );
                    self.DragEndData = [  ];
                    dragMarker( objVal, evt1, evt2 );

                end
            end
        end

        function dragEnded( self, evt1, evt2 )
            if any( isnan( evt1.IntersectionPoint ) ) || any( isnan( evt2.IntersectionPoint ) )
                return ;
            end
            tmp.IntersectionPoint = evt2.IntersectionPoint;
            tmp.HitObject = evt2.HitObject;
            tmp.Point = evt2.Point;

            evt2 = tmp;

            tmp.IntersectionPoint = evt1.IntersectionPoint;

            tmp.HitObject = evt1.HitObject;
            tmp.Point = evt1.Point;

            evt1 = tmp;
            if self.Grid.SnapToGrid
                evt2.IntersectionPoint( 1 ) = movePointToGrid( self, evt2.IntersectionPoint( 1 ) );
                evt2.IntersectionPoint( 2 ) = movePointToGrid( self, evt2.IntersectionPoint( 2 ) );
                evt1.IntersectionPoint( 1 ) = movePointToGrid( self, evt1.IntersectionPoint( 1 ) );
                evt1.IntersectionPoint( 2 ) = movePointToGrid( self, evt1.IntersectionPoint( 2 ) );
            else
                evt2.IntersectionPoint( 1 ) = round( evt2.IntersectionPoint( 1 ), 3 );
                evt2.IntersectionPoint( 2 ) = round( evt2.IntersectionPoint( 2 ), 3 );
                evt1.IntersectionPoint( 1 ) = round( evt1.IntersectionPoint( 1 ), 3 );
                evt1.IntersectionPoint( 2 ) = round( evt1.IntersectionPoint( 2 ), 3 );
            end
            if ~isempty( self.InteractionMode )
                p = pan( getFigure( self ) );
                if strcmpi( p.Enable, 'off' )



                    interactionData = exitInteraction( self, evt1, evt2 );
                    if strcmpi( interactionData.Mode, 'SelectionMode' )
                        self.notify( 'Selected', cad.events.SelectionEventData( interactionData.Data, 'Canvas' ) );
                    elseif strcmpi( interactionData.Mode, 'DrawRectangle' )
                        self.notify( 'AddShape', cad.events.AddEventData( 'Shape', 'Rectangle', interactionData.Data ) );

                    elseif strcmpi( interactionData.Mode, 'DrawCircle' )
                        self.notify( 'AddShape', cad.events.AddEventData( 'Shape', 'Circle', interactionData.Data ) );
                    elseif strcmpi( interactionData.Mode, 'DrawEllipse' )
                        self.notify( 'AddShape', cad.events.AddEventData( 'Shape', 'Ellipse', interactionData.Data ) );

                    end
                else
                    exitInteraction( self, evt1, evt2 );
                end
                return ;
            end
            if isempty( evt1.HitObject )
                return ;
            end

            if any( strcmpi( evt1.HitObject.Tag, { 'Shape', 'Feed', 'Via', 'Load' } ) )
                hitObj = evt1.HitObject;
                objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );

                if ~objVal.Info.EnableMove
                    return ;
                end

                if any( abs( evt1.IntersectionPoint( 1:2 ) - evt2.IntersectionPoint( 1:2 ) ) > 0 )
                    if ~isempty( self.SelectedObject )
                        selectedIdx = [ self.SelectedObject.Id ];
                        selectedType = { self.SelectedObject.Type };
                        if any( selectedIdx == objVal.Id )
                            data.Selection = { selectedType, selectedIdx };
                            data.StartPoint = evt1.IntersectionPoint;
                            data.EndPoint = evt2.IntersectionPoint;
                            self.notify( 'Move', cad.events.ValueChangedEventData( data ) );





                        else
                            drag( objVal, evt1, evt2 );
                            moved( self, objVal, objVal.Id, evt1.IntersectionPoint, evt2.IntersectionPoint );
                        end
                    else
                        drag( objVal, evt1, evt2 );
                        moved( self, objVal, objVal.Id, evt1.IntersectionPoint, evt2.IntersectionPoint );

                    end

                end
            elseif any( strcmpi( evt1.HitObject.Tag, { 'Resize', 'Rotate' } ) )
                if ~isempty( evt1.HitObject.UserData )


                    hitObj = evt1.HitObject;
                    objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                    if ~objVal.Info.EnableResize && strcmpi( evt1.HitObject.Tag, 'Resize' )
                        return ;
                    end
                    if isfield( objVal.Info, 'EnableRotate' ) && ~objVal.Info.EnableRotate && strcmpi( evt1.HitObject.Tag, 'Rotate' )
                        return ;
                    end
                    dragMarker( objVal, evt1, evt2 );
                    self.DragEndData = getBounds( objVal );
                    if evt1.HitObject.UserData.MarkerId ==  - 1
                        idval = hitObj.UserData.Id;
                        type = hitObj.UserData.Type;

                        rotated( self, objVal, objVal.Id, { self.RotateStartData, objVal.ResizeView.RotAngle }, mean( objVal.PatchObj.Vertices ) );
                        objVal = self.findObject( idval, type );
                        objVal.ResizeView.RotAngle = 90;
                        objVal.Selected = 0;
                        if ~isempty( self.SelectedObject )
                            selectedids = [ self.SelectedObject.Id ];
                            idsval = selectedids == objVal.Id;
                            if any( idsval )
                                self.SelectedObject( idsval ).unselect(  );
                            end
                        end

                    else
                        resized( self, objVal, objVal.Id, { self.DragStartData, self.DragEndData } )
                    end
                end
            end
        end

        function moved( self, objVal, id, startpt, endpt )
            self.notify( 'MoveShape', cad.events.AddEventData(  ...
                'Operation', 'Move', id, startpt, endpt ) )
        end
        function resized( self, objVal, id, data )
            self.notify( 'ResizeShape', cad.events.AddEventData(  ...
                'Operation', 'Resize', id, data ) );
        end

        function rotated( self, objVal, id, angles, axis )
            self.notify( 'RotateShape', cad.events.AddEventData(  ...
                'Operation', 'Rotate', id, angles, axis ) );
        end

        function val = movePointToGrid( self, val )


            val = round( val / self.Grid.GridSize ) * self.Grid.GridSize;
        end

        function drag( self, evt1, evt2 )
            if any( isnan( evt1.IntersectionPoint ) ) || any( isnan( evt2.IntersectionPoint ) )
                return ;
            end
            self.TooltipEvt = evt2;
            tmp.IntersectionPoint = evt2.IntersectionPoint;
            tmp.HitObject = evt2.HitObject;
            tmp.Point = evt2.Point;


            evt2 = tmp;

            tmp.IntersectionPoint = evt1.IntersectionPoint;

            tmp.HitObject = evt1.HitObject;
            tmp.Point = evt1.Point;

            evt1 = tmp;
            if self.Grid.SnapToGrid
                evt2.IntersectionPoint( 1 ) = movePointToGrid( self, evt2.IntersectionPoint( 1 ) );
                evt2.IntersectionPoint( 2 ) = movePointToGrid( self, evt2.IntersectionPoint( 2 ) );
                evt1.IntersectionPoint( 1 ) = movePointToGrid( self, evt1.IntersectionPoint( 1 ) );
                evt1.IntersectionPoint( 2 ) = movePointToGrid( self, evt1.IntersectionPoint( 2 ) );
            else
                evt2.IntersectionPoint( 1 ) = round( evt2.IntersectionPoint( 1 ), 3 );
                evt2.IntersectionPoint( 2 ) = round( evt2.IntersectionPoint( 2 ), 3 );
                evt1.IntersectionPoint( 1 ) = round( evt1.IntersectionPoint( 1 ), 3 );
                evt1.IntersectionPoint( 2 ) = round( evt1.IntersectionPoint( 2 ), 3 );

            end
            if ~isempty( self.InteractionMode )
                p = pan( getFigure( self ) );
                if strcmpi( p.Enable, 'off' )
                    updateInteraction( self, 'drag', evt1, evt2 );
                else
                    exitInteraction( self, evt1, evt2 );
                end
                return ;
            end
            if isempty( evt1.HitObject )
                return ;
            end
            if any( strcmpi( evt1.HitObject.Tag, { 'Shape', 'Feed', 'Via', 'Load' } ) )
                hitObj = evt1.HitObject;
                objVal = self.findObject( hitObj.UserData.Id, hitObj.Type );
                if ~objVal.Info.EnableMove
                    return ;
                end
                if ~isempty( self.SelectedObject )
                    selectedIdx = [ self.SelectedObject.Id ];
                    if any( selectedIdx == objVal.Id )
                        for i = 1:numel( self.SelectedObject )
                            drag( self.SelectedObject( i ), evt1, evt2 );
                        end
                    else
                        drag( objVal, evt1, evt2 );
                    end
                else
                    drag( objVal, evt1, evt2 );
                end
                [ newString, ~ ] = genCursorTextFromPos( self, mean( objVal.PatchObj.Vertices( :, 1 ) ),  ...
                    mean( objVal.PatchObj.Vertices( :, 2 ) ) );
                newString = [ 'Position: ', newString ];
                self.setCursorText( newString );
            elseif any( strcmpi( evt1.HitObject.Tag, { 'Resize', 'Rotate' } ) )
                if ~isempty( evt1.HitObject.UserData )

                    hitObj = evt1.HitObject;
                    objVal = self.findObject( hitObj.UserData.Id, hitObj.UserData.Type );
                    if ~objVal.Info.EnableResize && strcmpi( evt1.HitObject.Tag, 'Resize' )
                        return ;
                    end
                    if isfield( objVal.Info, 'EnableRotate' ) && ~objVal.Info.EnableRotate && strcmpi( evt1.HitObject.Tag, 'Rotate' )
                        return ;
                    end
                    dragMarker( objVal, evt1, evt2 );
                    if strcmpi( evt1.HitObject.Tag, 'Rotate' )
                        angleval = ( objVal.Info.Args.Angle + ( objVal.ResizeView.RotAngle - 90 ) );
                        if angleval < 0
                            angleval = mod( abs( angleval ), 360 ) *  - 1;
                        else
                            angleval = mod( angleval, 360 );
                        end
                        newString = [ 'Angle: ', num2str( angleval ) ];
                        self.setCursorText( newString );
                    end

                end
            end
        end



        function enterInteraction( self, mode, varargin )
            p = pan( getFigure( self ) );
            z = zoom( getFigure( self ) );

            if strcmpi( p.Enable, 'on' ) || strcmpi( z.Enable, 'on' ) || ( self.MB_LeftMousePress && isempty( varargin ) )






                self.MB_LeftMousePress = 0;
                self.MB_DragMotion = 0;
            end


            p.Enable = 'on';z.Enable = 'on';
            p.Enable = 'off';z.Enable = 'off';


            self.InteractionMode = mode;
            unselectAllSelection( self );
            switch mode
                case 'DrawingPolygon'
                    self.DragInteraction = 0;
                    self.InstructionalText.Visible = 'on';
                    self.InstructionalText.String = getString( message( 'antenna:pcbantennadesigner:PolygonText', newline ) );
                case 'SelectionMode'
                    self.DragInteraction = 1;
                    evt1 = varargin{ 1 };evt2 = varargin{ 2 };
                    if ~isempty( self.SelectionRect )
                        rectpatch = self.SelectionRect;
                        self.SelectionRect = [  ];
                        try
                            rectpatch.delete;
                        catch
                        end

                    end
                    self.PanInitialPoint = evt1.IntersectionPoint;
                    self.InteractionMode = 'SelectionMode';
                    fPt = evt1.IntersectionPoint;

                    lPt = evt2.IntersectionPoint;
                    vert = [ fPt( 1:2 ), 0;fPt( 1 ), lPt( 2 ), 0;lPt( 1:2 ), 0;lPt( 1 ), fPt( 2 ), 0 ];
                    self.SelectionRect = patch( getAxes( self ), 'Vertices', vert,  ...
                        'Faces', [ 1, 2, 3, 4 ], 'FaceColor', self.SelectionColor,  ...
                        'EdgeColor', self.SelectionColor, 'LineWidth', 2, 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                case 'DrawRectangle'
                    self.InstructionalText.Visible = 'on';
                    self.InstructionalText.String = getString( message( 'antenna:pcbantennadesigner:RectanglText' ) );
                    self.DragInteraction = 0;
                    if ~isempty( varargin )
                        self.DragInteraction = 1;
                        evt1 = varargin{ 1 };evt2 = varargin{ 2 };

                        if ~isempty( self.NewShapePatch )
                            shapepatch = self.NewShapePatch;
                            self.NewShapePatch = [  ];
                            try
                                shapepatch.delete;
                            catch
                            end

                        end
                        self.PanInitialPoint = evt1.IntersectionPoint;
                        fPt = evt1.IntersectionPoint;

                        lPt = evt2.IntersectionPoint;
                        [ vert, data ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapePatch = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', [ 1, 2, 3, 4 ], 'FaceColor', self.getColor,  ...
                            'EdgeColor', self.getColor, 'LineWidth', 2, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                        self.NewShapePatch.UserData = data;

                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', [ 1, 2, 3, 4 ], 'FaceColor', 'none',  ...
                            'EdgeColor', [ 0, 0, 0 ], 'LineWidth', 0.5, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                    end
                case 'DrawCircle'
                    self.InstructionalText.Visible = 'on';
                    self.InstructionalText.String = getString( message( 'antenna:pcbantennadesigner:CircleText' ) );
                    self.DragInteraction = 0;
                    if ~isempty( varargin )
                        self.DragInteraction = 1;
                        evt1 = varargin{ 1 };evt2 = varargin{ 2 };

                        if ~isempty( self.NewShapePatch )
                            shapepatch = self.NewShapePatch;
                            self.NewShapePatch = [  ];
                            try
                                shapepatch.delete;
                            catch
                            end

                        end
                        self.PanInitialPoint = evt1.IntersectionPoint;
                        fPt = evt1.IntersectionPoint;

                        lPt = evt2.IntersectionPoint;
                        [ minval, idx ] = min( abs( [ lPt( 1 ) - fPt( 1 ), lPt( 2 ) - fPt( 1 ) ] ) );
                        if idx == 1
                            if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                                lPt( 2 ) = fPt( 2 ) + abs( lPt( 1 ) - fPt( 1 ) );
                            elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                                lPt( 2 ) = fPt( 2 ) - abs( lPt( 1 ) - fPt( 1 ) );
                            else
                                lPt( 2 ) = fPt( 2 ) + ( lPt( 1 ) - fPt( 1 ) );
                            end
                        else
                            if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                                lPt( 1 ) = fPt( 1 ) - abs( lPt( 2 ) - fPt( 2 ) );
                            elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                                lPt( 1 ) = fPt( 1 ) + abs( lPt( 2 ) - fPt( 2 ) );
                            else
                                lPt( 1 ) = fPt( 1 ) + ( lPt( 2 ) - fPt( 2 ) );
                            end
                        end
                        evt2.IntersectionPoint( 1:2 ) = lPt( 1:2 );
                        self.TooltipEvt = evt2;
                        [ vert, data ] = genVertFromCornerPts( self, 'Circle', fPt, lPt );
                        self.NewShapePatch = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', 1:size( vert ), 'FaceColor', self.getColor,  ...
                            'EdgeColor', self.getColor, 'LineWidth', 2, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                        self.NewShapePatch.UserData = data;
                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', [ 1, 2, 3, 4 ], 'FaceColor', 'none',  ...
                            'EdgeColor', [ 0, 0, 0 ], 'LineWidth', 0.5, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                    end
                case 'DrawEllipse'
                    self.DragInteraction = 0;
                    self.InstructionalText.Visible = 'on';
                    self.InstructionalText.String = getString( message( 'antenna:pcbantennadesigner:EllipseText' ) );
                    if ~isempty( varargin )
                        self.DragInteraction = 1;
                        evt1 = varargin{ 1 };evt2 = varargin{ 2 };

                        if ~isempty( self.NewShapePatch )
                            shapepatch = self.NewShapePatch;
                            self.NewShapePatch = [  ];
                            try
                                shapepatch.delete;
                            catch
                            end

                        end
                        self.PanInitialPoint = evt1.IntersectionPoint;
                        fPt = evt1.IntersectionPoint;

                        lPt = evt2.IntersectionPoint;
                        if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                            lPt( 2 ) = fPt( 2 ) + abs( lPt( 1 ) - fPt( 1 ) ) / 2;
                        elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                            lPt( 2 ) = fPt( 2 ) - abs( lPt( 1 ) - fPt( 1 ) ) / 2;
                        else
                            lPt( 2 ) = fPt( 2 ) + ( lPt( 1 ) - fPt( 1 ) ) / 2;
                        end
                        evt2.IntersectionPoint( 1:2 ) = lPt( 1:2 );
                        self.TooltipEvt = evt2;
                        [ vert, data ] = genVertFromCornerPts( self, 'Ellipse', fPt, lPt );
                        self.NewShapePatch = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', 1:size( vert, 1 ), 'FaceColor', self.getColor,  ...
                            'EdgeColor', self.getColor, 'LineWidth', 2, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                        self.NewShapePatch.UserData = data;
                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox = patch( getAxes( self ), 'Vertices', vert,  ...
                            'Faces', [ 1, 2, 3, 4 ], 'FaceColor', 'none',  ...
                            'EdgeColor', [ 0, 0, 0 ], 'LineWidth', 0.5, 'LineStyle', '--', 'FaceAlpha', 0.25, 'EdgeAlpha', 0.5 );
                    end
            end
        end

        function [ vert, data ] = genVertFromCornerPts( self, ShapeType, fPt, lPt )
            switch ShapeType
                case 'Rectangle'
                    lwval = abs( [ fPt( 1 ) - lPt( 1 ), fPt( 2 ) - lPt( 2 ) ] );
                    length = lwval( 1 );
                    width = lwval( 2 );
                    center = ( fPt( 1:2 ) + lPt( 1:2 ) ) / 2;
                    vert = [ fPt( 1:2 ), 0;fPt( 1 ), lPt( 2 ), 0;lPt( 1:2 ), 0;lPt( 1 ), fPt( 2 ), 0 ];
                    data.Length = length;
                    data.Width = width;
                    data.Center = center;
                case 'Circle'
                    radiusVal = min( abs( [ fPt( 1 ) - lPt( 1 ), fPt( 2 ) - lPt( 2 ) ] ) ) / 2;
                    center = ( fPt( 1:2 ) + lPt( 1:2 ) ) / 2;
                    theta = linspace( 0, 2 * pi, 30 );
                    xval = radiusVal .* cos( theta ) + center( 1 );
                    yval = radiusVal .* sin( theta ) + center( 2 );
                    vert = [ xval( : ), yval( : ), zeros( 30, 1 ) ];
                    data.Radius = radiusVal;
                    data.Center = center;
                case 'Ellipse'
                    radiusVal = ( abs( [ fPt( 1 ) - lPt( 1 ), fPt( 2 ) - lPt( 2 ) ] ) );
                    center = ( fPt( 1:2 ) + lPt( 1:2 ) ) / 2;
                    theta = linspace( 0, 2 * pi, 30 );
                    xval = ( radiusVal( 1 ) / 2 ) .* cos( theta ) + center( 1 );
                    yval = ( radiusVal( 1 ) / 4 ) .* sin( theta ) + center( 2 );
                    vert = [ xval( : ), yval( : ), zeros( 30, 1 ) ];
                    data.MinorAxis = radiusVal( 1 ) / 2;
                    data.MajorAxis = radiusVal( 1 );
                    data.Center = center;
            end
        end

        function set.InteractionMode( self, val )
            self.InteractionMode = val;
        end
        function interactionData = exitInteraction( self, varargin )
            if isempty( self.InteractionMode )
                return ;
            end
            interactionData.Mode = self.InteractionMode;
            self.InstructionalText.Visible = 'off';
            switch self.InteractionMode
                case 'DrawingPolygon'

                    if isempty( self.PolygonDraw )
                        interactionData.Points = [  ];
                        interactionData.ErrorMsg = getString( message( "antenna:pcbantennadesigner:SelectThreePoints" ) );
                        self.InteractionMode = '';
                        return ;
                    end
                    Points = self.PolygonDraw.Points;
                    for i = 1:numel( self.PolygonDraw.Marker )
                        self.PolygonDraw.Marker( i ).delete;
                    end
                    for i = 1:numel( self.PolygonDraw.Line )
                        self.PolygonDraw.Line( i ).delete;
                    end
                    self.PolygonDraw = [  ];

                    polyobj = polyshape;
                    if ~isempty( Points )
                        if size( Points, 1 ) <= 2
                            interactionData.Points = [  ];
                            interactionData.ErrorMsg = getString( message( "antenna:pcbantennadesigner:SelectThreePoints" ) );
                            self.InteractionMode = '';
                            return ;
                        end
                        warning( 'off', 'MATLAB:polyshape:repairedBySimplify' );
                        polyobj.Vertices = Points( :, 1:2 );
                        Points = [ polyobj.Vertices, zeros( size( polyobj.Vertices, 1 ), 1 ) ];
                        warning( 'on', 'MATLAB:polyshape:repairedBySimplify' );
                        if any( isnan( polyobj.Vertices( :, 1 ) ) )
                            errormsg = getString( message( "antenna:pcbantennadesigner:IntersectionDetected" ) );
                            interactionData.Points = [  ];
                            interactionData.ErrorMsg = errormsg;
                            self.InteractionMode = '';
                            return ;
                        end

                        interactionData.Points = Points;
                        interactionData.ErrorMsg = '';
                    end

                case 'SelectionMode'
                    vert = self.SelectionRect.Vertices;
                    inflag = zeros( numel( self.ObjectStack ), 1 );
                    for i = 1:numel( inflag )
                        shapeVert = self.ObjectStack( i ).Info.ShapeObj.Vertices( :, 1:2 );
                        shapeVert = shapeVert( ~isnan( shapeVert( :, 1 ) ), : );
                        [ in, on ] = inpolygon( shapeVert( :, 1 ), shapeVert( :, 2 ), vert( :, 1 ), vert( :, 2 ) );
                        if all( in ) || all( on )
                            if i == 1
                                selectShape( self, self.ObjectStack( i ) )
                            else
                                selectShape( self, self.ObjectStack( i ), 1 );
                            end
                        end
                    end
                    if ~isempty( self.SelectedObject )
                        type = {  };
                        id = [  ];
                        for i = 1:numel( self.SelectedObject )
                            type = [ type;{ self.SelectedObject( i ).Type } ];
                            id = [ id;[ self.SelectedObject( i ).Id ] ];
                        end
                        data = { type, id };
                    else
                        data = [  ];
                    end
                    interactionData.Data = data;
                    self.SelectionRect.delete;
                    self.SelectionRect = [  ];
                    if ~isempty( self.SelectionRect )
                        self.SelectionRect.delete;
                        self.SelectionRect = [  ];
                    end
                case 'DrawRectangle'
                    if isempty( self.NewShapePatch )
                        interactionData = [  ];
                    else
                        interactionData.Type = 'Rectangle';
                        interactionData.Data = self.NewShapePatch.UserData;
                        self.NewShapePatch.delete;
                        self.NewShapePatch = [  ];
                        self.NewShapeBox.delete;
                        self.NewShapeBox = [  ];
                    end
                case 'DrawCircle'
                    if isempty( self.NewShapePatch )
                        interactionData = [  ];
                    else
                        interactionData.Type = 'Circle';
                        interactionData.Data = self.NewShapePatch.UserData;
                        self.NewShapePatch.delete;
                        self.NewShapePatch = [  ];
                        self.NewShapeBox.delete;
                        self.NewShapeBox = [  ];
                    end
                case 'DrawEllipse'
                    if isempty( self.NewShapePatch )
                        interactionData = [  ];
                    else
                        interactionData.Type = 'Ellipse';
                        interactionData.Data = self.NewShapePatch.UserData;
                        self.NewShapePatch.delete;
                        self.NewShapePatch = [  ];
                        self.NewShapeBox.delete;
                        self.NewShapeBox = [  ];
                    end
            end
            self.InteractionMode = [  ];
        end

        function updateInteraction( self, mouseMode, varargin )
            if isempty( self.InteractionMode )
                return ;
            end

            if xor( strcmpi( mouseMode, 'Drag' ), self.DragInteraction )
                exitInteraction( self, varargin );
                return ;
            end

            p = pan( getFigure( self ) );
            z = zoom( getFigure( self ) );
            p.Enable = 'off';z.Enable = 'off';

            switch self.InteractionMode
                case 'DrawingPolygon'
                    evt = varargin{ 1 };
                    setCursorText( self );
                    if ~any( isnan( evt.IntersectionPoint ) )
                        if isempty( self.PolygonDraw )
                            self.PolygonDraw.Points = [  ];
                            self.PolygonDraw.Marker = line( 'Parent', self.Axes,  ...
                                'XData', evt.IntersectionPoint( 1 ), 'YData', evt.IntersectionPoint( 2 ),  ...
                                'MarkerFaceColor', 'none', 'MarkerEdgeColor', 'k', 'MarkerSize', 10,  ...
                                'Marker', 'o' );
                            self.PolygonDraw.Line = [  ];
                        else
                            self.PolygonDraw.Marker( end  ).XData = evt.IntersectionPoint( 1 );
                            self.PolygonDraw.Marker( end  ).YData = evt.IntersectionPoint( 2 );

                        end

                        if numel( self.PolygonDraw.Marker ) >= 2
                            marker = self.PolygonDraw.Marker( end  - 1:end  );
                            xval = [ marker.XData ];
                            yval = [ marker.YData ];
                            set( self.PolygonDraw.Line( end  ), 'XData', xval, 'YData', yval );
                            self.TooltipEvt = evt;
                            setTooltipString( self, [ 'X: ', num2str( xval( end  ) ), newline,  ...
                                'Y: ', num2str( yval( end  ) ) ] );
                        end
                    end

                case 'SelectionMode'
                    evt1 = varargin{ 1 };
                    evt2 = varargin{ 2 };
                    fPt = evt1.IntersectionPoint;
                    lPt = evt2.IntersectionPoint;
                    vert = [ fPt( 1:2 ), 0;fPt( 1 ), lPt( 2 ), 0;lPt( 1:2 ), 0;lPt( 1 ), fPt( 2 ), 0 ];
                    if ~any( isnan( vert( : ) ) )
                        self.SelectionRect.Vertices = vert;
                    end
                case 'DrawRectangle'
                    if strcmpi( mouseMode, 'hover' )
                        setCursorText( self );
                    else
                        evt1 = varargin{ 1 };
                        evt2 = varargin{ 2 };
                        self.TooltipEvt = evt2;
                        fPt = evt1.IntersectionPoint;
                        lPt = evt2.IntersectionPoint;
                        [ vert, data ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapePatch.Vertices = vert;
                        setTooltipString( self, [ 'Length: ', num2str( data.Length ), newline,  ...
                            'Width: ', num2str( data.Width ), newline,  ...
                            'Center: ', mat2str( data.Center ) ] );
                        self.NewShapePatch.UserData = data;
                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox.Vertices = vert;
                    end
                case 'DrawCircle'
                    if strcmpi( mouseMode, 'hover' )

                        setCursorText( self );
                    else
                        evt1 = varargin{ 1 };
                        evt2 = varargin{ 2 };
                        self.TooltipEvt = evt2;
                        fPt = evt1.IntersectionPoint;
                        lPt = evt2.IntersectionPoint;
                        [ minval, idx ] = min( abs( [ lPt( 1 ) - fPt( 1 ), lPt( 2 ) - fPt( 1 ) ] ) );
                        if idx == 1
                            if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                                lPt( 2 ) = fPt( 2 ) + abs( lPt( 1 ) - fPt( 1 ) );
                            elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                                lPt( 2 ) = fPt( 2 ) - abs( lPt( 1 ) - fPt( 1 ) );
                            else
                                lPt( 2 ) = fPt( 2 ) + ( lPt( 1 ) - fPt( 1 ) );
                            end
                        else
                            if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                                lPt( 1 ) = fPt( 1 ) - abs( lPt( 2 ) - fPt( 2 ) );
                            elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                                lPt( 1 ) = fPt( 1 ) + abs( lPt( 2 ) - fPt( 2 ) );
                            else
                                lPt( 1 ) = fPt( 1 ) + ( lPt( 2 ) - fPt( 2 ) );
                            end
                        end
                        evt2.IntersectionPoint( 1:2 ) = lPt( 1:2 );
                        self.TooltipEvt = evt2;
                        [ vert, data ] = genVertFromCornerPts( self, 'Circle', fPt, lPt );
                        self.NewShapePatch.Vertices = vert;
                        setTooltipString( self, [ 'Radius: ', num2str( data.Radius ), newline,  ...
                            'Center: ', mat2str( data.Center ) ] );
                        self.NewShapePatch.UserData = data;
                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox.Vertices = vert;
                    end
                case 'DrawEllipse'
                    if strcmpi( mouseMode, 'hover' )
                        setCursorText( self );
                    else
                        evt1 = varargin{ 1 };
                        evt2 = varargin{ 2 };
                        self.TooltipEvt = evt2;
                        fPt = evt1.IntersectionPoint;
                        lPt = evt2.IntersectionPoint;
                        if ( lPt( 1 ) - fPt( 1 ) ) < 0 && ( lPt( 2 ) - fPt( 2 ) ) > 0
                            lPt( 2 ) = fPt( 2 ) + abs( lPt( 1 ) - fPt( 1 ) ) / 2;
                        elseif ( lPt( 1 ) - fPt( 1 ) ) > 0 && ( lPt( 2 ) - fPt( 2 ) ) < 0
                            lPt( 2 ) = fPt( 2 ) - abs( lPt( 1 ) - fPt( 1 ) ) / 2;
                        else
                            lPt( 2 ) = fPt( 2 ) + ( lPt( 1 ) - fPt( 1 ) ) / 2;
                        end
                        evt2.IntersectionPoint( 1:2 ) = lPt( 1:2 );
                        self.TooltipEvt = evt2;
                        [ vert, data ] = genVertFromCornerPts( self, 'Ellipse', fPt, lPt );
                        self.NewShapePatch.Vertices = vert;
                        setTooltipString( self, [ 'MinorAxis: ', num2str( data.MinorAxis ), newline,  ...
                            'MajorAxis: ', num2str( data.MajorAxis ), newline,  ...
                            'Center: ', mat2str( data.Center ) ] );
                        self.NewShapePatch.UserData = data;
                        [ vert, ~ ] = genVertFromCornerPts( self, 'Rectangle', fPt, lPt );
                        self.NewShapeBox.Vertices = vert;
                    end
            end
        end

        function cut( self )
            if ~self.ModelInfo.ActionsStatus( 1 )
                return ;
            end
            if isempty( self.SelectedObject )
                return ;
            end
            ids = [ self.SelectedObject.Id ];
            self.notify( 'Cut', cad.events.SelectionEventData( [  ] ) );

        end

        function copy( self )
            if ~self.ModelInfo.ActionsStatus( 2 )
                return ;
            end
            if isempty( self.SelectedObject )
                return ;
            end
            ids = [ self.SelectedObject.Id ];
            self.notify( 'Copy', cad.events.SelectionEventData( [  ] ) );
        end

        function deleteObj( self )
            if ~self.ModelInfo.ActionsStatus( 4 )
                return ;
            end
            self.notify( 'Delete', cad.events.SelectionEventData( [  ] ) );
        end

        function undo( self )
            self.notify( 'Undo' );
        end
        function redo( self )
            self.notify( 'Redo' );
        end

        function paste( self )
            if ~self.ModelInfo.ActionsStatus( 3 )
                return ;
            end
            self.notify( 'Paste' );
        end

        function objVal = findObject( self, id, type )
            objVal = [  ];
            if isempty( self.ObjectStack )
                return ;
            end
            ids = [ self.ObjectStack.Id ];
            if any( ids == id )
                objVal = self.ObjectStack( ids == id );
            end
            if isempty( objVal )
                objVal = [  ];
                return ;
            end
            types = { objVal.Type };
            if any( strcmpi( type, types ) )
                objVal = objVal( strcmpi( type, types ) );
            end


        end

        function objVal = findOverlayObj( self, id, type )
            ids = cell2mat( cellfun( @( x )x.Id, self.OverlayObj, 'uniformOutput', false ) );
            idx = ids == id;
            objVal = self.OverlayObj{ idx };
        end
        function delete( self )
            if ~isempty( self.Figure ) && isvalid( self.Figure )
                clf( self.Figure );
            end
        end

        function deleteObjectStack( self )

            objStack = self.ObjectStack;
            for i = 1:numel( objStack )
                objStack.delete;
            end
            self.ObjectStack = [  ];
        end

    end
    events
        AddShape
        AddOperation
        MoveShape
        ResizeShape
        DeleteShape
        RotateShape
        Selected
        Move
    end
end



