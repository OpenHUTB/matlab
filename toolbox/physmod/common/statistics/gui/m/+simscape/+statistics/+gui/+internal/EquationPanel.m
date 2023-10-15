classdef EquationPanel < handle
    events
        SelectionChanged
    end
    properties ( SetAccess = private )
        Data table = lDefaultData(  )
        UITable
    end
    properties ( Access = private )
        Tag = "Equations"
    end
    properties
        Sources
    end
    properties ( Dependent, SetAccess = private )
        Selection
    end
    properties ( Access = private )
        RowIds
    end
    methods
        function obj = EquationPanel( data, parent, args )
            arguments
                data table = lDefaultData(  )
                parent( 1, 1 )matlab.graphics.Graphics = uigridlayout( uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
                args( 1, : )cell = {  }
            end
            obj.Sources = data;
            tbl = findobj( parent.Children, 'Tag', obj.Tag, '-depth', 0 );
            tblData = lEquationData( data );
            if isempty( tbl )
                obj.UITable = uitable( parent, 'Data', tblData, args{ : }, 'Tag', obj.Tag );
                obj.UITable.SelectionChangedFcn = @( varargin )broadcastSelectionChanged( obj, varargin );
                obj.UITable.SelectionType = 'row';
                obj.UITable.ColumnSortable = [ true, true ];
                obj.UITable.ColumnWidth = { 'auto', 'auto', 'fit', 'fit' };
                obj.UITable.ColumnName = { 'Block', 'Component', 'Ln', 'Col' };
                obj.UITable.RowName = {  };
                obj.UITable.RowStriping = false;
            else
                obj.UITable = tbl;
                set( obj.UITable, 'Data', tblData );
            end
        end

        function out = get.Selection( obj )
            out = obj.UITable.Selection;
        end

        function set.Sources( obj, srcs )
            tblData = lEquationData( srcs );
            set( obj.UITable, 'Data', tblData );
        end

    end
    methods ( Access = private )
        function broadcastSelectionChanged( obj, varargin )
            notify( obj, 'SelectionChanged' );
        end
    end
end

function tbl = lEquationData( srcs )
blk = srcs.BlockPath;
[ cmp, ln, col ] = lFileInfo( srcs{ :, 'SourceCode' } );
tbl = [ blk( : ), cmp( : ), ln( : ), col( : ) ];
end
function [ cmp, ln, col ] = lFileInfo( s )
if isempty( s )
    cmp = {  };
    ln = {  };
    col = {  };
else
    cmp = cellfun( @( f )lComp( f ), { s.File }, 'UniformOutput', false );
    ln = { s.Line };
    col = { s.Column };
end

    function cmp = lComp( f )
        [ ~, cmp ] = fileparts( f );
    end
end

function t = lDefaultData(  )
t = struct2table( struct( 'BlockPath', {  }, 'SourceCode', {  } ) );
end

