classdef PartitionsComponent < simscape.statistics.gui.util.internal.GuiComponent
    properties ( Constant )
        Layout = lLayout(  );
    end
    properties ( Constant, Access = private )
        Tag = lPartitions(  );
    end
    properties ( Access = private )
        PartitionsView = [  ]
        EquationsView = [  ]
        VariablesView = [  ]
        Data
        SelectionListener
    end
    methods
        function obj = PartitionsComponent( data )
            obj.Data = data;
        end
        function render( obj, figuresMap )
            if isempty( obj.PartitionsView )
                fig = figuresMap.( lPartitions(  ) );
                parent = findobj( fig.Children, 'Tag', lPartitions(  ), '-depth', 0 );
                if isempty( parent )
                    parent = uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', lPartitions(  ) );
                end
                obj.PartitionsView = simscape.statistics.gui.internal.PartitionsPanel(  ...
                    obj.Data, parent );
                obj.SelectionListener =  ...
                    addlistener( obj.PartitionsView, 'SelectionChanged',  ...
                    @( varargin )obj.updateSources(  ) );

                fig = figuresMap.( lVariables(  ) );
                parent = findobj( fig.Children, 'Tag', lVariables(  ), '-depth', 0 );
                if isempty( parent )
                    parent = uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', lVariables(  ) );
                end
                obj.VariablesView =  ...
                    simscape.statistics.gui.internal.BlockSourcesTable(  ...
                    obj.currentVariableSources, parent );

                fig = figuresMap.( lEquations(  ) );
                parent = findobj( fig.Children, 'Tag', lEquations(  ), '-depth', 0 );
                if isempty( parent )
                    parent = uigridlayout( fig, 'ColumnWidth', { '1x' }, 'RowHeight', { '1x' }, 'Tag', lEquations(  ) );
                end
                obj.EquationsView =  ...
                    simscape.statistics.gui.internal.EquationPanel(  ...
                    obj.currentEquationSources(  ), parent );
            end
        end
        function out = label( ~, tag )
            out = "";
            switch tag
                case lPartitions(  )
                    out = "Partitions";
                case lVariables(  )
                    out = "Variables";
                case lEquations(  )
                    out = "Equations";
            end
        end
        function out = description( obj )
            arguments
                obj( 1, 1 )
            end
            out = obj.Data.Properties.Description;
        end
    end
    methods ( Access = private )
        function updateSources( obj )
            obj.VariablesView.Sources = obj.currentVariableSources(  );
            obj.EquationsView.Sources = obj.currentEquationSources(  );
        end
        function out = currentVariableSources( obj )
            s = obj.PartitionsView.Selection;
            if ~isempty( s )
                v = obj.Data{ s, 'NumVariables' };
                out = v.Sources;
            else
                out = lDefaultVariableSources(  );
            end
        end
        function out = currentEquationSources( obj )
            s = obj.PartitionsView.Selection;
            if ~isempty( s )
                e = obj.Data{ s, 'NumEquations' };
                out = e.Sources;
            else
                out = lDefaultEquationsSources(  );
            end
        end
    end
end

function tag = lPartitions(  )
tag = "Partitions";
end

function tag = lVariables(  )
tag = "Variables";
end

function tag = lEquations(  )
tag = "Equations";
end

function layout = lLayout(  )
layout = simscape.statistics.gui.util.internal.Layout(  ...
    [ lPartitions(  );lVariables(  );lEquations(  ) ] );
end

function t = lDefaultVariableSources(  )
t = struct2table( struct( 'VariablePath', {  }, 'Description', {  }, 'SID', {  } ) );
end

function t = lDefaultEquationsSources(  )
t = struct2table( struct( 'BlockPath', {  }, 'SourceCode', {  } ) );
end
