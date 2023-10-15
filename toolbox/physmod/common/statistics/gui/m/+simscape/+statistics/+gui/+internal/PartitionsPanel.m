classdef PartitionsPanel < handle
    events
        SelectionChanged
    end
    properties ( Dependent )
        Selection
    end
    properties ( Access = private )
        UITable
    end
    properties ( Constant, Access = private )
        Tag = 'PartitionsTable';
    end
    methods
        function obj = PartitionsPanel( data, parent )
            arguments
                data table = lDefault(  )
                parent( 1, 1 )matlab.graphics.Graphics = uigridlayout(  ...
                    uifigure, 'RowHeight', { '1x' }, 'ColumnWidth', { '1x' } )
            end

            tblData = lData( data );
            tbl = findobj( parent, 'Tag', obj.Tag );
            if isempty( tbl )
                obj.UITable = uitable( parent, 'Data', tblData );

                obj.UITable.RowStriping = false;
                obj.UITable.ColumnWidth = { 'auto', 'auto', 'fit', 'fit', 'fit', 'fit', 'fit' };
                obj.UITable.SelectionType = 'row';
                obj.UITable.ColumnName = lLabels(  );
                obj.UITable.Tag = obj.Tag;
            else
                obj.UITable = tbl;
                set( obj.UITable, 'Data', tblData );
            end

            obj.UITable.SelectionChangedFcn = @( varargin )broadCastSelectionChanged( obj );
        end

        function out = get.Selection( obj )
            out = obj.UITable.Selection;
        end
    end
    methods ( Access = private )
        function broadCastSelectionChanged( obj )
            notify( obj, 'SelectionChanged' );
        end
    end
end

function d = lData( t )
d = [ t{ :, 'SolverType' },  ...
    t{ :, 'EquationType' },  ...
    lVal( t{ :, 'NumVariables' } ),  ...
    lVal( t{ :, 'NumEquations' } ),  ...
    num2cell( t{ :, 'NumModes' } ),  ...
    num2cell( t{ :, 'NumCachedMatrices' } ),  ...
    num2cell( t{ :, 'MemoryEstimate' } ) ];
    function v = lVal( str )
        v = arrayfun( @( s )s.Value, str, 'UniformOutput', false );
    end
end

function lables = lLabels(  )
lables = {
    sprintf( '\nSolver Type' )
    sprintf( '\nEquation Type' )
    sprintf( '\nVariables' )
    sprintf( '\nEquations' )
    sprintf( '\nModes' )
    sprintf( 'Cached\nMatrices' )
    sprintf( 'Memory\nEstimate' ) };
end

function ids = lIds(  )
ids = { 'SolverType'
    'EquationType'
    'NumVariables'
    'NumEquations'
    'NumModes'
    'NumCachedMatrices'
    'MemoryEstimate' };
end

function t = lDefault(  )
t = cell2table( repamt(  ), 'VariableNames', lIds(  ) );
end

