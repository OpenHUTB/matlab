classdef ComponentSelector < simscape.statistics.gui.util.internal.GuiComponent
    properties ( Constant )
        Layout = lLayout(  )
    end
    events
        SelectionChanged
    end
    properties ( Dependent )
        Selection( 1, 1 )string
    end
    properties ( Dependent, SetAccess = private )
        IDs( :, 1 )string{ lMustBeUnique }
        Labels( :, 1 )string
        Components( :, 1 )simscape.statistics.gui.util.internal.GuiComponent
    end
    properties ( Access = private )
        UITable
        UIDescription
        ComponentData( :, 1 )struct
        CachedSelection( 1, 1 )string = missing
    end
    methods
        function obj = ComponentSelector( componentTree )
            arguments
                componentTree( :, 1 )simscape.statistics.gui.util.internal.ComponentTree = lEmptyComponent(  )
            end
            obj.setComponentTree( componentTree );
        end
        function render( obj, figureMap )
            if isempty( obj.UITable ) || ~isvalid( obj.UITable ) || ancestor( obj.UITable.Parent, 'figure' ) ~= figureMap.( lSelection(  ) )
                parent = uigridlayout( figureMap.( lSelection(  ) ), 'RowHeight', { 'fit', '1x' }, 'ColumnWidth', { 'fit' }, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } );
                obj.UITable = uitable( parent, 'Data', obj.Labels );
                obj.UITable.ColumnName = {  };
                obj.UITable.RowName = {  };
                obj.UITable.RowStriping = false;
                obj.UITable.SelectionType = 'row';
                obj.UITable.SelectionChangedFcn = @( varargin )broadcastSelectionChanged( obj );
                obj.UITable.Multiselect = "off";
                obj.UIDescription = uitextarea( parent, "Value", "This is my description.", 'Tag', "Description" );
            else
                assert( ~isempty( obj.UITable ) && isvalid( obj.UITable ) );
                set( obj.UITable, 'Data', obj.Labels );
                removeStyle( obj.UITable );
                rows = find( ~contains( obj.IDs, '.' ) );
                if ~isempty( rows )
                    addStyle( obj.UITable, uistyle( 'FontWeight', 'bold' ), 'row', rows );
                end
            end
            if ismember( obj.CachedSelection, obj.IDs )
                obj.Selection = obj.CachedSelection;
            else
                obj.Selection = missing;
            end
            obj.CachedSelection = obj.Selection;
        end
        function setComponentTree( obj, componentTree )
            arguments
                obj( 1, 1 )
                componentTree( :, 1 )simscape.statistics.gui.util.internal.ComponentTree
            end
            [ labels, ids, Components ] = lComponentList( componentTree );
            lMustBeUnique( [ ids{ : } ] );
            obj.CachedSelection = obj.Selection;
            obj.ComponentData = struct( 'Label', labels, "ID", ids, "Component", Components );
        end
        function out = get.Selection( obj )
            out = string( missing );
            if ~isempty( obj.UITable ) && ~isempty( obj.UITable.Selection )
                out = obj.IDs( obj.UITable.Selection );
            end
        end
        function set.Selection( obj, selection )
            arguments
                obj( 1, 1 )
                selection( 1, 1 )string
            end
            if ~isempty( obj.UITable ) && isvalid( obj.UITable )
                obj.UITable.Selection = find( strcmp( selection, obj.IDs ) );
            end
            if ~strcmp( selection, obj.Selection )
                obj.broadcastSelectionChanged(  )
            end
        end
        function out = get.IDs( obj )
            out = string( [ obj.ComponentData.ID ]' );
        end
        function out = get.Labels( obj )
            out = string( [ obj.ComponentData.Label ]' );
        end
        function out = get.Components( obj )
            out = [ obj.ComponentData.Component ]';
        end
        function out = component( obj )
            out = [  ];
            if ~ismissing( obj.Selection )
                out = obj.ComponentData( strcmp( obj.Selection, obj.IDs ) ).Component;
            end
        end
        function out = label( ~, tag )
            out = tag;
            if strcmp( tag, lSelection(  ) )
                out = "Selection";
            end
        end
        function out = description( ~ )
            arguments
                ~
            end
            out = string( missing );
        end
    end
    methods ( Access = private )
        function broadcastSelectionChanged( obj )
            obj.CachedSelection = obj.Selection;
            v = obj.component(  );
            if ~isempty( v )
                obj.UIDescription.Value = v.description(  );
            else
                obj.UIDescription.Value = string( missing );
            end
            notify( obj, 'SelectionChanged' );
        end
    end
end

function [ entries, ids, components ] = lComponentList( componentTree, parent, tab )
arguments
    componentTree( :, 1 )simscape.statistics.gui.util.internal.ComponentTree = simscape.statistics.gui.util.internal.ComponentTree(  )
    parent( 1, : )string{ lMustBeIds } = [  ]
    tab( 1, 1 )string = ""
end
ids = {  };
entries = {  };
components = {  };
for idx = 1:numel( componentTree )
    vn = componentTree( idx );
    [ newEntries, newIds, newComponents ] = lComponentList( vn.Children, [ parent, vn.ID ], strcat( tab, repmat( char( 160 ), 1, 2 ) ) );
    ids = [ ids;{ strjoin( [ parent, vn.ID ], '.' ) };newIds ];%#ok<AGROW>
    components = [ components;{ vn.Component };newComponents ];%#ok<AGROW>
    if ismissing( vn.Label )
        label = vn.ID;
    else
        label = vn.Label;
    end
    entries = [ entries;{ strcat( tab, label ) };newEntries ];%#ok<AGROW>
end
end

function str = lSelection(  )
str = "Selection";
end

function l = lLayout(  )
l = simscape.statistics.gui.util.internal.Layout( lSelection(  ) );
end

function lMustBeIds( ids )
arrayfun( @mustBeValidVariableName, ids );
end

function lMustBeUnique( ids )
arrayfun( @( id )lMustBeIds( strsplit( id, "." ) ), ids );
assert( numel( unique( ids ) ) == numel( ids ), "IDs must be unique." );
end

function o = lEmptyComponent(  )
import simscape.statistics.gui.util.internal.ComponentTree;
import simscape.statistics.gui.util.internal.TextComponent
o = repmat( ComponentTree( TextComponent(  ), 'x' ), 0, 0 );
end

