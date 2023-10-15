classdef ConstraintsTable < handle
    properties ( SetAccess = private )
        Data
        UITable
    end
    properties ( Dependent, SetAccess = private )
        Selection( 1, : )cell
        Sources
    end
    properties ( Access = private )
        RowIds
    end
    properties ( Constant )
        Tag = "ConstraintsTable";
    end
    events
        SelectionChanged
    end
    methods
        function obj = ConstraintsTable( data, parent )
            arguments
                data table = table
                parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
            end
            obj.Data = data;
            maybeTable = findobj( parent, 'Tag', obj.Tag );
            tblData = [ obj.Data{ :, 'Name' }, num2cell( obj.Data{ :, 'Value' } ) ];
            obj.RowIds = obj.Data{ :, 'ID' };
            if isempty( maybeTable )
                obj.UITable = uitable( parent,  ...
                    'Data', tblData,  ...
                    'SelectionType', 'row',  ...
                    'RowStriping', false,  ...
                    'ColumnFormat', { 'char', 'char' },  ...
                    'Tag', obj.Tag );
                obj.UITable.ColumnName = { 'Constraint', '#' };
                obj.UITable.ColumnWidth = { 'fit', 'auto' };
                obj.UITable.RowName = {  };
                obj.UITable.Multiselect = 'off';
                obj.UITable.SelectionChangedFcn = @( varargin )obj.broadcastSelectionChanged;
            else
                obj.UITable = maybeTable;
                set( obj.UITable, 'Data', tblData );
                obj.Selection = obj.RowIds( obj.UITable.Selection );
            end

        end
        function out = get.Selection( obj )
            out = obj.RowIds( obj.UITable.Selection );
        end
        function out = get.Sources( obj )
            s = obj.Selection;
            if isempty( s )
                out = lDefaultSources(  );
                return
            end
            out = obj.Data{ strcmp( s{ 1 }, obj.RowIds ), 'Sources' }{ 1 };

        end
        function set.Selection( obj, val )
            isRow = arrayfun( @( c )isequal( c, val ), obj.RowIds );
            obj.UITable.Selection = find( isRow );
        end
    end
    methods ( Access = private )
        function broadcastSelectionChanged( obj )
            notify( obj, 'SelectionChanged' );
        end
    end
end

function d = lDefaultSources(  )
d = struct2table( struct( 'VariablePath', {  }, 'Description', {  }, 'SID', {  } ) );
end

